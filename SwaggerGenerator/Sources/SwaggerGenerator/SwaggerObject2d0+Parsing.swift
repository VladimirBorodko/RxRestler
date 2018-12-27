//
//  SwaggerObject2d0+Parsing.swift
//  SwaggerGenerator
//
//  Created by Vladimir on 05.12.2018.
//

import Foundation

extension SwaggerObject2d0 {
    func parseSecurityDefinitions(model: inout ApiModel, collector: Collector) {
        let collector = collector.appending("securityDefinitions")
        for (key, value) in securityDefinitions ?? [:] {
            let collector = collector.appending(key)
            collector.collect { model.security[key] = try value.parseSecurity() }
        }
    }

    func parseDefinitions(model: inout ApiModel, collector: Collector) {
        let collector = collector.appending("definitions")
        for (key, value) in definitions ?? [:] {
            let collector = collector.appending(key)
            collector.collect {
                model.definitions[key] = try .init(description: value.description, type: value.parseType())
            }
        }
    }

    func parseResponses(model: inout ApiModel, collector: Collector) {
        let collector = collector.appending("responses")
        for (key, value) in responses ?? [:] {
            let collector = collector.appending(key)
            collector.collect {
                let type = try value.schema.t1?.parseType() ?? value.schema.t2?.parseType() ?? Collector.throw("type not specified")
                let headers = value.headers?
                    .reduce(into: [String: ApiModel.Header]()) { accumulator, pair in
                        let collector = collector.appending("headers").appending(pair.key)
                        collector.collect {
                            let type = try pair.value.t2?.parseType() ?? Collector.throw("type not specified")
                            accumulator[pair.key] = .init(description: pair.value.t1?.description, type: type)
                        }
                    }
                    ?? [:]
                model.responses[key] = .init(description: value.description, type: type, headers: headers)
            }
        }
    }

    func parsePaths(model: inout ApiModel, collector: Collector) {
        let collector = collector.appending("paths")
        for (key, value) in paths {
            let collector = collector.appending(key)
            let collectiveParameters = value.parameters?
                .reduce(into: ApiModel.Parameters(), collector.appending("parameters").parseParameter(parameters:poly:))
                ?? [:]
            model.requests += [
                ApiModel.Method.get: value.get,
                .head: value.head,
                .post: value.post,
                .put: value.put,
                .delete: value.delete,
                .options: value.options,
                .patch: value.patch
            ]
                .compactMap { pair in
                    let collector = collector.appending(pair.key.rawValue)
                    guard let operation = pair.value else { return nil }
                    let parameters = (operation.parameters ?? [])
                        .reduce(into: ApiModel.Parameters(), collector.appending("parameters").parseParameter(parameters:poly:))
                        .reduce(into: collectiveParameters) { $0[$1.key] = $1.value }
                    let responses = operation.responses?
                        .reduce(into: [String: ApiModel.ResponseType]()) { accumulator, response in
                            accumulator[response.key] = collector.appending("responses").appending(response.key).collect { return try response.value.t1?
                                .parseResponse()
                                ?? response.value.t2
                                .flatMap{$0.parseResponse(collector: collector)}
                                .map{ .local($0) }
                                ?? .void
                            }
                        } ?? [:]
                    return ApiModel.Request(
                        url: key,
                        method: pair.key,
                        parameters: parameters,
                        description: operation.description,
                        responses: responses,
                        deprecated: operation.deprecated ?? false,
                        security: []
                    )
//                    collector.appending(pair.key.rawValue).catch { try parseOperation(url: key, method: pair.key, operation: pair.value) }
                }
//                .reduce(into: [ApiModel.Method: ApiModel.Request]()) { accumulator, request in
//                    guard var request = request else { return }
//                    request.parameters = collectiveParameters.reduce(into: request.parameters) { if $0[$1.key] == nil { $0[$1.key] = $1.value } }
//                    accumulator[request.method] = request
//                }
        }
//        print(model.requests.map { "\($0.url)" + $0.parameters.reduce("") { $0 + "\n" + $1.key.name + String(reflecting: $1.value.type) } }.joined(separator: "\n"))
    }
}

private extension Collector {
    func parseParameter(parameters: inout ApiModel.Parameters, poly: SwaggerObject2d0.PolyParameter) {
        guard let name = poly.t1?.name else {
            collect("lack `name` field".error)
            return
        }
        guard let location = poly.t1?.location else {
            collect("lack `in` field".error)
            return
        }
        let parameter = ApiModel.Parameter(name: name, location: location.parseLocation())
        guard parameters[parameter] == nil else {
            collect("dublicate parameter \(name) in \(location)".error)
            return
        }
        parameters[parameter] = appending(name)
            .collect {
                return try poly.t1?.schema?.t1?.parseType()
                    ?? poly.t1?.schema?.t2?.parseType()
                    ?? poly.t2?.parseType()
                    ?? Collector.throw("poly parameter type not specified")
            }.map {
                ApiModel.Property(description: poly.t2?.description, type: $0, required: location.parameterRequired || poly.t1?.required?.t1 ?? false)
            }
    }

}

private func parseOperation(url: String, method: ApiModel.Method, operation: SwaggerObject2d0.OperationObject?) throws -> ApiModel.Request? {
//    ApiModel.Request()
    throw "not implemented".error
}

private extension SwaggerObject2d0.PathItemObject {

}

private extension SwaggerObject2d0.ParameterObject.Location {
    func parseLocation() -> ApiModel.Parameter.Location {
        switch self {
        case .body: return .body
        case .formData: return .formData
        case .header: return .header
        case .path: return .path
        case .query: return .query
        }
    }
    var parameterRequired: Bool {
        switch self {
        case .body: return false
        case .formData: return false
        case .header: return false
        case .path: return true
        case .query: return false
        }
    }
}

private extension SwaggerObject2d0.SecuritySchemeObject {
    func parseSecurity() throws -> ApiModel.Security {
        switch type {
        case .basic: return .basic(description: description)
        case .apiKey:
            guard let name = name else { throw "lack `name` field".error }
            guard let location = location else { throw "lack `in` field".error }
            switch location {
            case .query: return .apiKeyQuery(description: description, name: name)
            case .header: return .apiKeyHeader(description: description, name: name)
            }
        case .oauth2:
            guard let flow = flow else { throw "lack `flow` field".error }
            let scopes = self.scopes ?? [:]
            switch flow {
            case .implicit:
                guard let authorizationUrl = authorizationUrl else { throw "lack `authorizationUrl` field".error }
                return .oauthImplicit(description: description, scopes: scopes, authorizationUrl: authorizationUrl)
            case .password:
                guard let tokenUrl = tokenUrl else { throw "lack `tokenUrl` field".error }
                return .oauthPassword(description: description, scopes: scopes, tokenUrl: tokenUrl)
            case .application:
                guard let tokenUrl = tokenUrl else { throw "lack `tokenUrl` field".error }
                return .oauthApplication(description: description, scopes: scopes, tokenUrl: tokenUrl)
            case .accessCode:
                guard let authorizationUrl = authorizationUrl else { throw "lack `authorizationUrl` field".error }
                guard let tokenUrl = tokenUrl else { throw "lack `tokenUrl` field".error }
                return .oauthAccessCode(description: description, scopes: scopes, authorizationUrl: authorizationUrl, tokenUrl: tokenUrl)
            }
        }

    }
}

private extension SwaggerObject2d0.SchemaObject {
    func parseType() throws -> ApiModel.ValueType {
        switch type {
        case .integer:
            guard let format = format else { throw "lack `format` field for type \(type)".error }
            switch format {
            case .int32: return .int32
            case .uint32: return .uint32
            case .int64: return .int64
            case .uint64: return .uint64
            default: throw "unrecognized format \(format) for type \(type)".error
            }
        case .number:
            guard let format = format else { throw "lack `format` field for type \(type)".error }
            switch format {
            case .float: return .float
            case .double: return .double
            default: throw "unrecognized format \(format) for type \(type)".error
            }
        case .boolean: return .bool
        case .file: return .data
        case .array:
            guard let items = items else { throw "lack `items` field for type \(type)".error }
            guard let itemsType = try items.t1?.parseType() ?? items.t2?.parseType() else { throw "\(type) items type not specified".error }
            let serialization = collectionFormat.flatMap { ApiModel.ValueType.Array.Serialization(rawValue: $0.rawValue) } ?? .csv
            return .array(.init(type: itemsType, maxItems: maxItems, minItems: minItems, uniqueItems: uniqueItems ?? false, serialization: serialization))
        case .object:
            let required = self.required?.t2?.reduce(into: Set<String>()) { $0.insert($1) } ?? []
            let properties = try self.properties?
                .reduce(into: [String: ApiModel.Property]()) { accumulator, pair in
                    guard let type = try pair.value.t1?.parseType() ?? pair.value.t2?.parseType() else {
                        throw "type of \(pair.key) property not defined".error
                    }
                    accumulator[pair.key] = .init(description: pair.value.t2?.description, type: type, required: required.contains(pair.key))
                }
                ?? [:]
            return .object(properties)
        case .string:
            guard let format = format else {
                guard let enumeration = enumeration else { return .stringRaw }
                if enumeration.isEmpty { throw "empty enum".error }
                let cases = try enumeration.reduce(into: Set<String>()) { accumulator, element in
                    guard let string = element.string else { throw "enum case type mismatch".error }
                    guard !accumulator.contains(string) else { throw "enum not unique case \(string)".error }
                    accumulator.insert(string)
                }
                return .enumeration(cases)
            }
            switch format {
            case .byte: return .stringBase64
            case .date: return .date
            case .dateTime: return .date
            case .password: return .stringRaw
            default: throw "unrecognized format \(format) for type \(type)".error
            }
        }

    }

}

private extension SwaggerObject2d0.ReferenceObject {
    private func trim(_ prefix: String) -> String? {
        guard reference.starts(with: prefix) else { return nil }
        return String(reference.dropFirst(reference.count - prefix.count))
    }

    func parseType() throws -> ApiModel.ValueType {
        if let ref = trim("#/definitions/") { return .definition(ref) }
        throw "definition dereferencing failed \(reference)".error
    }

    func parseResponse() throws -> ApiModel.ResponseType {
        if let ref = trim("#/responses/") { return .response(ref) }
        throw "response dereferencing failed \(reference)".error
    }
}

private extension SwaggerObject2d0.ResponseObject {
    func parseResponse(collector: Collector) -> ApiModel.Response? {
        guard let type = collector.collect({ try schema.t1?.parseType() ?? schema.t2?.parseType() ?? Collector.throw("type not specified") }) else {
            return nil
        }
        let headers = self.headers?
            .reduce(into: [String: ApiModel.Header]()) { accumulator, pair in
                let collector = collector.appending("headers").appending(pair.key)
                collector.collect {
                    let type = try pair.value.t2?.parseType() ?? Collector.throw("type not specified")
                    accumulator[pair.key] = .init(description: pair.value.t1?.description, type: type)
                }
            }
            ?? [:]
        return .init(description: description, type: type, headers: headers)
    }
}
