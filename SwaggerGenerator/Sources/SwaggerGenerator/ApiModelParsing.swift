//
//  ApiModelParsing.swift
//  SwaggerGenerator
//
//  Created by Vladimir on 05.12.2018.
//

import Foundation

protocol ApiModelParsing {
    func parse(model: inout ApiModel, collector: Collector)
}

extension ApiModelParsing {
    func parse(_ collector: Collector) -> ApiModel {
        var model = ApiModel()
        parse(model: &model, collector: collector.appending("parse"))
        return model
    }
}

extension SwaggerObject2d0: ApiModelParsing {
    func parse(model: inout ApiModel, collector: Collector) {
        model.basePath = basePath
        model.host = host
        let collector = collector.appending("spec_2_0")
        parseSecurityDefinitions(model: &model, collector: collector)
        print("Finished parsing Security Definitions total: \(model.security.count) of: \(String(describing: securityDefinitions?.count))")
        parseDefinitions(model: &model, collector: collector)
        print("Finished parsing Definitions total: \(model.definitions.count) of: \(String(describing: definitions?.count))")
        parseResponses(model: &model, collector: collector)
        print("Finished parsing Reponses total: \(model.responses.count) of: \(String(describing: responses?.count))")
        parsePaths(model: &model, collector: collector)
        print("Finished parsing Requests total: \(model.requests.count) of: \(paths.count) params: \(model.requests.flatMap{$0.parameters}.count)")
    }
}
