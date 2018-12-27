//
//  Swagger.swift
//  SwaggerGenerator
//
//  Created by Vladimir on 07.11.2018.
//

import Foundation

class SwaggerObject2d0: Decodable {
    /// Required. Provides metadata about the API. The metadata can be used by the clients if needed.
    var info: InfoObject
    /// The host (name or ip) serving the API. This MUST be the host only and does not include the scheme nor sub-paths.
    /// It MAY include a port. If the host is not included, the host serving the documentation is to be used (including the port).
    /// The host does not support path templating.
    var host: String?
    /// The base path on which the API is served, which is relative to the host. If it is not included, the API is served directly under the host.
    /// The value MUST start with a leading slash (/). The basePath does not support path templating.
    var basePath: String?
    /// The transfer protocol of the API. Values MUST be from the list: "http", "https", "ws", "wss".
    /// If the schemes is not included, the default scheme to be used is the one used to access the Swagger definition itself.
    var schemes: [Scheme]?
    /// A list of MIME types the APIs can consume. This is global to all APIs but can be overridden on specific API calls.
    /// Value MUST be as described under Mime Types.
    var consumes: [String]?
    /// A list of MIME types the APIs can produce. This is global to all APIs but can be overridden on specific API calls.
    /// Value MUST be as described under Mime Types.
    var produces: [String]?
    /// Required. The available paths and operations for the API.
    var paths: [String: PathItemObject]
    /// An object to hold data types produced and consumed by operations.
    var definitions: [String: SchemaObject]?
    /// An object to hold parameters that can be used across operations. This property does not define global parameters for all operations.
    var parameters: [String: ParameterObject]?
    /// An object to hold responses that can be used across operations. This property does not define global responses for all operations.
    var responses: [String: ResponseObject]?
    /// Security scheme definitions that can be used across the specification.
    var securityDefinitions: [String: SecuritySchemeObject]?
    /// A declaration of which security schemes are applied for the API as a whole.
    /// The list of values describes alternative security schemes that can be used (that is, there is a logical OR between the security requirements).
    /// Individual operations can override this definition.
    var security: [[String: [String]]]?
    /// A list of tags used by the specification with additional metadata. The order of the tags can be used to reflect on their order by the parsing tools.
    /// Not all tags that are used by the Operation Object must be declared.
    /// The tags that are not declared may be organized randomly or based on the tools' logic. Each tag name in the list MUST be unique.
    var tags: [Tag]?

    class SecuritySchemeObject: Decodable {
        /// Required. The type of the security scheme. Valid values are "basic", "apiKey" or "oauth2"
        var type: Kind
        /// A short description for security scheme.
        var description: String?
        /// Required. The name of the header or query parameter to be used.
        var name: String?
        /// Required The location of the API key. Valid values are "query" or "header".
        var location: Location?
        /// Required. The flow used by the OAuth2 security scheme. Valid values are "implicit", "password", "application" or "accessCode".
        var flow: Flow?
        /// Required. The authorization URL to be used for this flow. This SHOULD be in the form of a URL.
        var authorizationUrl: String?
        /// Required. The token URL to be used for this flow. This SHOULD be in the form of a URL.
        var tokenUrl: String?
        /// Required. The available scopes for the OAuth2 security scheme.
        var scopes: [String: String]?

        enum Kind: String, Decodable { case basic, apiKey, oauth2 }
        enum Location: String, Decodable { case query, header }
        enum Flow: String, Decodable { case implicit, password, application, accessCode }
        enum CodingKeys: String, CodingKey { case type, description, name, location = "in", flow, authorizationUrl, tokenUrl, scopes }
    }

    class InfoObject: Decodable {
        /// Required. The title of the application.
        var title: String?
        /// A short description of the application. GFM syntax can be used for rich text representation.
        var description: String?
        /// The Terms of Service for the API.
        var termsOfService: String?
        /// The contact information for the exposed API.
        var contact: ContactObject?
        /// The license information for the exposed API.
        var license: LicenseObject?
        /// Required Provides the version of the application API (not to be confused with the specification version).
        var version: String

        class ContactObject: Decodable {
            /// The identifying name of the contact person/organization.
            var name: String?
            /// The URL pointing to the contact information. MUST be in the format of a URL.
            var url: String?
            /// The email address of the contact person/organization. MUST be in the format of an email address.
            var email: String?
        }

        class LicenseObject: Decodable {
            /// Required. The license name used for the API.
            var name: String
            /// A URL to the license used for the API. MUST be in the format of a URL.
            var url: String?
        }
    }

    enum Scheme: String, Decodable { case http, https, ws, wss }

    class Tag: Decodable {
        /// Required. The name of the tag.
        var name: String?
        /// Additional external documentation for this tag.
        var description: String?
    }

    class PathItemObject: Decodable {
        /// A definition of a GET operation on this path.
        var get: OperationObject?
        /// A definition of a HEAD operation on this path.
        var head: OperationObject?
        /// A definition of a POST operation on this path.
        var post: OperationObject?
        /// A definition of a PUT operation on this path.
        var put: OperationObject?
        /// A definition of a DELETE operation on this path.
        var delete: OperationObject?
        /// A definition of a OPTIONS operation on this path.
        var options: OperationObject?
        /// A definition of a PATCH operation on this path.
        var patch: OperationObject?
        /// A list of parameters that are applicable for all the operations described under this path.
        /// These parameters can be overridden at the operation level, but cannot be removed there.
        /// The list MUST NOT include duplicated parameters. A unique parameter is defined by a combination of a name and location.
        /// The list can use the Reference Object to link to parameters that are defined at the Swagger Object's parameters.
        /// There can be one "body" parameter at most.
        var parameters: [PolyParameter]?
    }

    typealias PolyParameter = Poly.Objects2<ParameterObject, SchemaObject>
    typealias PolySchema =  Poly.Objects2<ReferenceObject, SchemaObject>
    typealias PolyHeader = Poly.Objects2<HeaderObject, SchemaObject>
    typealias PolyResponse = Poly.Objects2<ReferenceObject, ResponseObject>
    typealias PolyRequired = Poly.Objects2<Bool, [String]>


    class OperationObject: Decodable {
        /// A list of tags for API documentation control. Tags can be used for logical grouping of operations by resources or any other qualifier.
        var tags: [String]?
        /// A short summary of what the operation does. For maximum readability in the swagger-ui, this field SHOULD be less than 120 characters.
        var summary: String?
        /// A verbose explanation of the operation behavior. GFM syntax can be used for rich text representation.
        var description: String?
        /// Unique string used to identify the operation. The id MUST be unique among all operations described in the API.
        /// Tools and libraries MAY use the operationId to uniquely identify an operation, therefore,
        /// it is recommended to follow common programming naming conventions.
        var operationId: String?
        /// A list of MIME types the operation can consume. This overrides the consumes definition at the Swagger Object.
        /// An empty value MAY be used to clear the global definition. Value MUST be as described under Mime Types.
        var consumes: [String]?
        /// A list of MIME types the operation can produce. This overrides the produces definition at the Swagger Object.
        /// An empty value MAY be used to clear the global definition. Value MUST be as described under Mime Types.
        var produces: [String]?
        /// A list of parameters that are applicable for this operation.
        /// If a parameter is already defined at the Path Item, the new definition will override it, but can never remove it.
        /// The list MUST NOT include duplicated parameters. A unique parameter is defined by a combination of a name and location.
        /// The list can use the Reference Object to link to parameters that are defined at the Swagger Object's parameters.
        /// There can be one "body" parameter at most.
        var parameters: [PolyParameter]?
        /// Required. The list of possible responses as they are returned from executing this operation.
        var responses: [String: PolyResponse]?
        /// The transfer protocol for the operation. Values MUST be from the list: "http", "https", "ws", "wss".
        /// The value overrides the Swagger Object schemes definition.
        var schemes: [Scheme]?
        /// Declares this operation to be deprecated. Usage of the declared operation should be refrained. Default value is false.
        var deprecated: Bool?
        /// A declaration of which security schemes are applied for this operation.
        /// The list of values describes alternative security schemes that can be used (that is, there is a logical OR between the security requirements).
        /// This definition overrides any declared top-level security. To remove a top-level security declaration, an empty array can be used.
        var security: [[String: [String]]]?
    }

    class ParameterObject: Decodable {
        /// Required. The name of the parameter. Parameter names are case sensitive.
        /// If in is "path", the name field MUST correspond to the associated path segment from the path field in the Paths Object.
        /// See Path Templating for further information.
        /// For all other cases, the name corresponds to the parameter name used based on the in property.
        var name: String
        /// Required. The location of the parameter. Possible values are "query", "header", "path", "formData" or "body".
        var location: Location
        /// A brief description of the parameter. This could contain examples of use. GFM syntax can be used for rich text representation.
        var description: String?
        /// Determines whether this parameter is mandatory. If the parameter is in "path", this property is required and its value MUST be true.
        /// Otherwise, the property MAY be included and its default value is false.
        var required: PolyRequired?
        /// Required. The schema defining the type used for the body parameter.
        var schema: PolySchema?

        enum Location: String, Decodable { case query, header, path, formData, body }
        enum CodingKeys: String, CodingKey { case name, location = "in", description, required, schema }
    }

    class ReferenceObject: Decodable {
        var reference: String

        enum CodingKeys: String, CodingKey { case reference = "$ref" }
    }

    class ResponseObject: Decodable {
        /// Required. A short description of the response. GFM syntax can be used for rich text representation.
        var description: String?
        /// A definition of the response structure. It can be a primitive, an array or an object.
        /// If this field does not exist, it means no content is returned as part of the response.
        /// As an extension to the Schema Object, its root type value may also be "file". This SHOULD be accompanied by a relevant produces mime-type.
        var schema: PolySchema

        /// A list of headers that are sent with the response.
        var headers: [String: PolyHeader]?
    }

    class HeaderObject: Decodable {
        /// A short description of the header.
        var description: String?
    }

    class SchemaObject: Decodable {
        /// Adds support for polymorphism.
        /// The discriminator is the schema property name that is used to differentiate between other schema that inherit this schema.
        /// The property name used MUST be defined at this schema and it MUST be in the required property list.
        /// When used, the value MUST be the name of this schema or any schema that inherits it.
        var discriminator: String?
        /// Relevant only for Schema "properties" definitions. Declares the property as "read only".
        /// This means that it MAY be sent as part of a response but MUST NOT be sent as part of the request.
        /// Properties marked as readOnly being true SHOULD NOT be in the required list of the defined schema. Default value is false.
        var readOnly: Bool?
        /// A free-form property to include an example of an instance for this schema.
        var example: String?
        /// GFM syntax can be used for rich text representation
        var description: String?
        /// Required. The type of the parameter.
        /// Since the parameter is not located at the request body, it is limited to simple types (that is, not an object).
        /// The value MUST be one of "string", "number", "integer", "boolean", "array" or "file". If type is "file",
        /// the consumes MUST be either "multipart/form-data", " application/x-www-form-urlencoded" or both and the parameter MUST be in "formData".
        var type: Kind
        /// The extending format for the previously mentioned type. See Data Type Formats for further details.
        var format: Format?
        /// Sets the ability to pass empty-valued parameters.
        /// This is valid only for either query or formData parameters and allows you to send a parameter with a name only or an empty value.
        /// Default value is false.
        var allowEmptyValue: Bool?
        /// Required if type is "array". Describes the type of items in the array.
        var items: PolySchema?
        /// Determines the format of the array if type array is used. Possible values are:
        /// csv - comma separated values foo,bar.
        /// ssv - space separated values foo bar.
        /// tsv - tab separated values foo\tbar.
        /// pipes - pipe separated values foo|bar.
        /// multi - corresponds to multiple parameter instances instead of multiple values for a single instance foo=bar&foo=baz.
        /// This is valid only for parameters in "query" or "formData".
        /// Default value is csv.
        var collectionFormat: CollectionFormat?
        /// Declares the value of the parameter that the server will use if none is provided, for example a "count" to control the number
        /// of results per page might default to 100 if not supplied by the client in the request.
        /// (Note: "default" has no meaning for required parameters.) See https://tools.ietf.org/html/draft-fge-json-schema-validation-00#section-6.2.
        /// Unlike JSON Schema this value MUST conform to the defined type for this parameter.
        var defaults: Poly.Value?
        var maximum: Poly.Value?
        var exclusiveMaximum: Bool?
        var minimum: Poly.Value?
        var exclusiveMinimum: Bool?
        var maxLength: Int?
        var minLength: Int?
        var pattern: String?
        var maxItems: Int?
        var minItems: Int?
        var uniqueItems: Bool?
        var enumeration: [Poly.Value]?
        var multipleOf: Int?
        var maxProperties: Int?
        var minProperties: Int?
        var required: PolyRequired?
        //        var allOf
        var properties: [String: PolySchema]?
        var additionalProperties: [String: PolySchema]?
        var title: String?

        enum Kind: String, Decodable { case string, number, integer, boolean, array, file, object }
        enum Format: String, Decodable { case int32, uint32, int64, uint64, float, double, byte, binary, date, dateTime = "date-time", password }
        enum CollectionFormat: String, Decodable { case csv, ssv, tsv, pipes, multi }
        enum CodingKeys: String, CodingKey {
            case discriminator, readOnly, example, description, type, format, allowEmptyValue, items, collectionFormat, defaults = "default", maximum
            case exclusiveMaximum, exclusiveMinimum, maxLength, minLength, pattern, maxItems, minItems, uniqueItems, enumeration = "enum", multipleOf
            case maxProperties, minProperties, required, properties, additionalProperties, title
        }
    }
}
