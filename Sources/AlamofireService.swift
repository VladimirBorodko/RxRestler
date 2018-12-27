import Foundation
import Alamofire
import RxSwift

final class AlamofireService<State> {

    private let sessionManager: SessionManager
    private let errorSubject = PublishSubject<Error>()
    private let stateSubject: BehaviorSubject<State>
    private var state: State { didSet { stateSubject.onNext(state) } }
    private let serial: SerialDispatchQueueScheduler
    private let global: ConcurrentDispatchQueueScheduler

    var errorCast: Observable<Error> { return errorSubject.observeOn(global) }
    var stateCast: Observable<State> { return stateSubject.observeOn(global) }

    init(
        session manager: SessionManager = .default,
        initial state: State,
        serialQos: DispatchQoS = .userInitiated,
        globalQos: DispatchQoS = .default
    ) {
        sessionManager = manager
        self.state = state
        stateSubject = BehaviorSubject(value: state)
        serial = SerialDispatchQueueScheduler(qos: serialQos,
                                              internalSerialQueueName: String(reflecting: AlamofireService<State>.self),
                                              leeway: .nanoseconds(0))
        global = ConcurrentDispatchQueueScheduler(qos: globalQos)
    }

    fileprivate func fetch<T: AlamofireFetchable>(_ fetchable: T) -> Observable<T.Response> where T.State == State {
        return Observable<() throws -> DataRequest>
            .deferred { [weak self] in
                guard let self = self else { throw Deallocated() }
                return .just { [state = self.state, sessionManager = self.sessionManager] in
                    return try fetchable.construct(state: state, sessionManager: sessionManager)
                }
            }
            .subscribeOn(serial)
            .observeOn(global)
            .flatMap { makeRequest -> Observable<AlamofireResponse> in
                let request = try makeRequest()
                request.resume()
                return Observable.create { observer in
                    request.delegate.queue.addOperation {
                        observer.on(.next(AlamofireResponse(response: request.response, data: request.delegate.data, error: request.delegate.error)))
                        observer.on(.completed)
                    }
                    return Disposables.create { request.cancel() }
                }
            }
            .observeOn(serial)
            .map { [weak self] in
                guard let self = self else { throw Deallocated() }
                return try fetchable.serialize(response: $0, mutate: &self.state) as T.Response
            }
            .do(onError: { [weak self] in self?.errorSubject.onNext($0) })
            .observeOn(global)
    }
}

private struct Deallocated: Error { }

extension AlamofireFetchable {
    func fetch(service: AlamofireService<State>) -> Observable<Response> { return service.fetch(self) }
}
