import Foundation
import Alamofire

protocol JsonFetchable: AlamofireFetchable where State: AlamofireHeadersSharing {
    func constructJsonRequest(state: State) throws -> JsonRequest
}

extension JsonFetchable {
    func construct(state: State, sessionManager: SessionManager) throws -> DataRequest {
        switch try constructJsonRequest(state: state) {
        case let .get(url: url, query: query):
            return sessionManager.request(url, method: .get, parameters: query, encoding: URLEncoding.default, headers: state.headers)
        case let .post(url: url, json: json):
            return sessionManager.request(url, method: .post, parameters: json, encoding: JSONEncoding.default, headers: state.headers)
        case let .delete(url: url, json: json):
            return sessionManager.request(url, method: .delete, parameters: json, encoding: JSONEncoding.default, headers: state.headers)
        case let .patch(url: url, json: json):
            return sessionManager.request(url, method: .patch, parameters: json, encoding: JSONEncoding.default, headers: state.headers)
        }
    }
}

protocol AlamofireHeadersSharing {
    var headers: [String: String] { get }
}

enum JsonRequest {
    case get(url: URL, query: [String: Any])
    case post(url: URL, json: [String: Any])
    case delete(url: URL, json: [String: Any])
    case patch(url: URL, json: [String: Any])
}
