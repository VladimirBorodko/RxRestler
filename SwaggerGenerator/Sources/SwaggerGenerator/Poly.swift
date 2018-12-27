//
//  Poly.swift
//  SwaggerGenerator
//
//  Created by Vladimir on 05.12.2018.
//

import Foundation

enum Poly {
    class Value: Decodable {
        var bool: Bool? = nil
        var string: String? = nil
        var double: Double? = nil
        var float: Float? = nil
        var int: Int? = nil
        var int8: Int8? = nil
        var int16: Int16? = nil
        var int32: Int32? = nil
        var int64: Int64? = nil
        var uint: UInt? = nil
        var uint8: UInt8? = nil
        var uint16: UInt16? = nil
        var uint32: UInt32? = nil
        var uint64: UInt64? = nil

        required init(from decoder: Decoder) throws {
            guard let value = try? decoder.singleValueContainer() else { return }
            func decode<T: Decodable>() -> T? { return try? value.decode(T.self) }
            bool = decode()
            string = decode()
            double = decode()
            float = decode()
            int = decode()
            int8 = decode()
            int16 = decode()
            int32 = decode()
            int64 = decode()
            uint = decode()
            uint8 = decode()
            uint16 = decode()
            uint32 = decode()
            uint64 = decode()
        }
    }

    class Objects2<T1: Decodable,T2: Decodable>: Decodable {
        var t1: T1?
        var t2: T2?
        required init(from decoder: Decoder) throws {
            t1 = try? T1(from: decoder)
            t2 = try? T2(from: decoder)
        }
    }

    class Objects3<T1: Decodable,T2: Decodable,T3: Decodable>: Decodable {
        var t1: T1?
        var t2: T2?
        var t3: T3?
        required init(from decoder: Decoder) throws {
            t1 = try? T1(from: decoder)
            t2 = try? T2(from: decoder)
            t3 = try? T3(from: decoder)
        }
    }

    class Objects4<T1: Decodable,T2: Decodable,T3: Decodable,T4: Decodable>: Decodable {
        var t1: T1?
        var t2: T2?
        var t3: T3?
        var t4: T4?
        required init(from decoder: Decoder) throws {
            t1 = try? T1(from: decoder)
            t2 = try? T2(from: decoder)
            t3 = try? T3(from: decoder)
            t4 = try? T4(from: decoder)
        }
    }
}
