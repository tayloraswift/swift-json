import JSON
import Testing

@Suite enum IntegerOverflow {
    @Test static func AsInt8() {
        Self.expect(256, overflows: Int8.self)
    }

    @Test static func AsInt16() throws {
        try Self.decode(256, to: Int16.self)
    }

    @Test static func AsInt32() throws {
        try Self.decode(256, to: Int32.self)
    }

    @Test static func AsInt64() throws {
        try Self.decode(256, to: Int64.self)
    }
    @Test static func AsInt64Max() throws {
        try Self.decode(Int64.max, to: Int64.self)
    }
    @Test static func AsInt64Min() throws {
        try Self.decode(Int64.min, to: Int64.self)
    }

    @Test static func AsInt128Inline() throws {
        let field: JSON.FieldDecoder<Never?> = .init(
            key: nil,
            value: .number(.inline(.init(sign: .minus, units: UInt64.max)))
        )

        #expect(try field.decode() == -Int128.init(UInt64.max))
    }
    @Test static func AsInt128Min() throws {
        try Self.decode(Int128.min, to: Int128.self)
    }
    @Test static func AsInt128Max() throws {
        try Self.decode(Int128.max, to: Int128.self)
    }

    @Test static func AsInt() throws {
        try Self.decode(256, to: Int.self)
    }

    @Test static func AsUInt8() {
        Self.expect(256, overflows: UInt8.self)
    }

    @Test static func AsUInt16() throws {
        try Self.decode(256, to: UInt16.self)
    }

    @Test static func AsUInt32() throws {
        try Self.decode(256, to: UInt32.self)
    }

    @Test static func AsUInt64() throws {
        try Self.decode(256, to: UInt64.self)
    }
    @Test static func AsUInt64Max() throws {
        try Self.decode(UInt64.max, to: UInt64.self)
    }

    @Test static func AsUInt128() throws {
        try Self.decode(256, to: UInt128.self)
    }
    @Test static func AsUInt128Max() throws {
        try Self.decode(UInt128.max, to: UInt128.self)
    }

    @Test static func AsUInt() throws {
        try Self.decode(256, to: UInt.self)
    }
}
extension IntegerOverflow {
    private static func expect<Signed>(_ value: Int64, overflows: Signed.Type)
        where Signed: SignedInteger & JSONDecodable {
        let field: JSON.FieldDecoder<Never?> = .init(
            key: nil,
            value: .number(.init(value))
        )

        #expect(throws: JSON.DecodingError<Never?>.self) {
            let _: Signed = try field.decode()
        }
    }
    private static func decode<Signed>(
        _ value: Signed,
        to: Signed.Type
    ) throws where Signed: SignedInteger & JSONDecodable {
        let field: JSON.FieldDecoder<Never?> = .init(
            key: nil,
            value: .number(.init(value))
        )

        #expect(try field.decode() == value)
    }

    private static func expect<Unsigned>(_ value: UInt64, overflows: Unsigned.Type)
        where Unsigned: UnsignedInteger & JSONDecodable {
        let field: JSON.FieldDecoder<Never?> = .init(
            key: nil,
            value: .number(.init(value))
        )

        #expect(throws: JSON.DecodingError<Never?>.self) {
            let _: Unsigned = try field.decode()
        }
    }
    private static func decode<Unsigned>(
        _ value: Unsigned,
        to: Unsigned.Type
    ) throws where Unsigned: UnsignedInteger & JSONDecodable {
        let field: JSON.FieldDecoder<Never?> = .init(
            key: nil,
            value: .number(.init(value))
        )

        #expect(try field.decode() == value)
    }
}
