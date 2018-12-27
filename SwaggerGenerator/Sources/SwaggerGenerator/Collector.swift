//
//  Collector.swift
//  SwaggerGenerator
//
//  Created by Vladimir on 07.12.2018.
//

import Foundation


extension String {
    var error: Error {
        struct StringError: Error, CustomStringConvertible, CustomDebugStringConvertible {
            let string: String
            var description: String { return string }
            var debugDescription: String { return string }
        }
        return StringError(string: self)
    }
}

struct Collector {
    typealias ErrorHandler = (Error) -> Void
    private let errorHandler: (Error) -> Void
    private(set) var stackTrace: [String] = []
    init (_ errorHandler: @escaping ErrorHandler) { self.errorHandler = errorHandler }

    func appending(_ element: String) -> Collector {
        var result = self
        result.stackTrace.append(element)
        return result
    }

    func collect(_ error: Error) {
        errorHandler("Error: \(stackTrace.joined(separator: ".")): \(error)".error)
    }

    func collect(_ execute: () throws -> Void) {
        do { try execute() } catch { collect(error) }
    }

    func collect<T>(_ execute: () throws -> T) -> T? {
        do {
            return try execute()
        } catch {
            collect(error)
            return nil
        }
    }

    static func `throw`<T>(_ message: String) throws -> T {
        throw message.error
    }
}

