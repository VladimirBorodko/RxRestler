//
//  Swagger.swift
//  SwaggerGenerator
//
//  Created by Vladimir on 05.12.2018.
//

import Foundation

class Swagger: Decodable {
    var swagger: String
    var object: ApiModelParsing

    required init(from decoder: Decoder) throws {
        swagger = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .swagger)
        switch swagger {
        case "2.0": object = try SwaggerObject2d0(from: decoder)
        default: throw "Swagger specification \(swagger) not supported".error
        }
    }

    enum CodingKeys: String, CodingKey { case swagger }
}
