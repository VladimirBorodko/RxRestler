import Foundation
import Alamofire

protocol AlamofireResponsible {
    associatedtype Response
    associatedtype State
    // TODO: separate serialization and state mutation APTV-2252
    func serialize(response: AlamofireResponse, mutate state: inout State) throws -> Response
}

struct AlamofireResponse {
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
}

protocol AlamofireFetchable: AlamofireResponsible {
    func construct(state: State, sessionManager: SessionManager) throws -> DataRequest
}
