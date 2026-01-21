import JSON
import Testing

/// i do not know why this has to be a separate test suite. there is some kind of macro bug in
/// the swift-testing framework...
@Suite enum ParsingNumerics {
    struct Wrapper<T>: JSONObjectEncodable, JSONObjectDecodable
        where T: JSONEncodable & JSONDecodable {
        enum CodingKey: String, Sendable {
            case value
        }

        let value: T

        init(value: T) {
            self.value = value
        }
        init(json: borrowing JSON.ObjectDecoder<CodingKey>) throws {
            self.value = try json[.value].decode()
        }
        func encode(to json: inout JSON.ObjectEncoder<CodingKey>) {
            json[.value] = self.value
        }
    }

    @Test(
        arguments: [
            ("0", .init(0)),
            ("\(UInt64.max)", .init(UInt64.max)),
            ("\(Int64.max)", .init(Int64.max)),
            ("\(Int64.min)", .init(Int64.min)),
            ("nan", .nan),
            ("snan", .snan),
            ("inf", .infinity(.plus)),
            ("-inf", .infinity(.minus)),
            ("1.0000000000000000000012345", .fallback("1.0000000000000000000012345"))
        ] as [(String, JSON.Number)],
    ) static func Number(_ expression: String, _ expected: JSON.Number) throws {
        guard case JSON.Node.number(let number)? = try .init(parsingFragment: expression) else {
            Issue.record()
            return
        }

        #expect(number == expected)
    }

    @Test(
        arguments: [
            (-123456789.123456789123456789123456789, "-123456789.12345679"),
            (-1, "-1.0"),
            (-0.5, "-0.5"),
            (0, "0.0"),
            (0.5, "0.5"),
            (1, "1.0"),
            (123.456e+50, "1.23456e+52"),
            (123.456e-50, "1.23456e-48"),
            (123456789.123456789123456789123456789, "123456789.12345679"),
            (.nan, "nan"),
            (.signalingNaN, "snan"),
            (-.infinity, "-inf"),
            (+.infinity, "inf")
        ] as [(Double, String)],
    ) static func NumberRoundtripping(_ value: Double, string: String) throws {
        let encoded: Wrapper<Double> = .init(value: value)
        let json: JSON = .encode(encoded)
        let decoded: Wrapper<Double> = try json.decode()

        #expect("\(json)" == "{\"value\":\(string)}")
        #expect(encoded.value.bitPattern == decoded.value.bitPattern)
    }

    @Test(
        arguments: [
            Int128.min,
            0,
            Int128.max,
        ] as [Int128],
    ) static func BigIntRoundtripping(_ value: Int128) throws {
        let encoded: Wrapper<Int128> = .init(value: value)
        let json: JSON = .encode(encoded)
        let decoded: Wrapper<Int128> = try json.decode()

        #expect("\(json)" == "{\"value\":\(value)}")
        #expect(encoded.value == decoded.value)
    }

    @Test(
        arguments: [
            0,
            UInt128.max,
        ] as [UInt128],
    ) static func BigIntRoundtrippingUnsigned(_ value: UInt128) throws {
        let encoded: Wrapper<UInt128> = .init(value: value)
        let json: JSON = .encode(encoded)
        let decoded: Wrapper<UInt128> = try json.decode()

        #expect("\(json)" == "{\"value\":\(value)}")
        #expect(encoded.value == decoded.value)
    }
}
