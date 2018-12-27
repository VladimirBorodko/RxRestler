//
//  ApiModel.swift
//  SwaggerGenerator
//
//  Created by Vladimir on 29.11.2018.
//

import Foundation

struct ApiModel {
    var definitions: [String: Definition] = [:]
    var responses: [String: Response] = [:]
    var requests: [Request] = []
    var basePath: String? = nil
    var host: String? = nil
    var security: [String: Security] = [:]

    enum ValueType {
        case int32, uint32, int64, uint64, float, double, data, date, bool, stringRaw, stringBase64
        case definition(String), enumeration(Set<String>), object([String: Property])
        indirect case array(Array)

        struct Array {
            var type: ValueType
            var maxItems: Int?
            var minItems: Int?
            var uniqueItems: Bool
            var serialization: Serialization

            enum Serialization: String { case csv, ssv, tsv, pipes, multi }
        }
    }

    struct Property {
        var description: String?
        var type: ValueType
        var required: Bool
    }

    struct Parameter: Hashable {
        var name: String
        var location: Location

        enum Location: Hashable { case query, header, path, formData, body }
    }

    typealias Parameters = [Parameter: Property]

    struct Definition {
        var description: String?
        var type: ValueType
    }

    struct Request {
        var url: String
        var method: Method
        var parameters: Parameters = [:]
        var description: String? = nil
        var responses: [String: ResponseType] = [:]
        var deprecated: Bool = false
        var security: Set<String> = []
    }
    
    enum ResponseType {
        case local(Response)
        case response(String)
        case void
    }

    struct Response {
        var description: String?
        var type: ValueType
        var headers: [String: Header]
    }
    
    struct Header {
        var description: String?
        var type: ValueType
    }

    enum Method: String, Hashable {
        case get
        case head
        case post
        case put
        case delete
        case connect
        case options
        case trace
        case patch
    }

    enum Security {
        case basic(description: String?)
        case apiKeyQuery(description: String?, name: String)
        case apiKeyHeader(description: String?, name: String)
        case oauthImplicit(description: String?, scopes: [String: String], authorizationUrl: String)
        case oauthPassword(description: String?, scopes: [String: String], tokenUrl: String)
        case oauthApplication(description: String?, scopes: [String: String], tokenUrl: String)
        case oauthAccessCode(description: String?, scopes: [String: String], authorizationUrl: String, tokenUrl: String)
    }

//    enum Property {
//        case
//    }
}
