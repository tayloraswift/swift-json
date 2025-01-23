import JSON
import Testing

extension IntegerOverflow
{
    @Test
    static func AsInt8()
    {
        Self.expect(256, overflows: Int8.self)
    }

    @Test
    static func AsInt16()
    {
        Self.decode(256, to: Int16.self)
    }

    @Test
    static func AsInt32()
    {
        Self.decode(256, to: Int32.self)
    }

    @Test
    static func AsInt64()
    {
        Self.decode(256, to: Int64.self)
    }

    @Test
    static func AsInt64Max()
    {
        Self.decode(Int64.max, to: Int64.self)
    }

    @Test
    static func AsInt64Min()
    {
        Self.decode(Int64.min, to: Int64.self)
    }

    @Test
    static func AsInt()
    {
        Self.decode(256, to: Int.self)
    }

    @Test
    static func AsUInt8()
    {
        Self.expect(256, overflows: UInt8.self)
    }

    @Test
    static func AsUInt16()
    {
        Self.decode(256, to: UInt16.self)
    }

    @Test
    static func AsUInt32()
    {
        Self.decode(256, to: UInt32.self)
    }

    @Test
    static func AsUInt64()
    {
        Self.decode(256, to: UInt64.self)
    }

    @Test
    static func AsUInt64Max()
    {
        Self.decode(UInt64.max, to: UInt64.self)
    }

    @Test
    static func AsUInt()
    {
        Self.decode(256, to: UInt.self)
    }
}
struct IntegerOverflow
{
    private
    static func expect<Signed>(_ value:Int64, overflows:Signed.Type)
        where Signed:SignedInteger & JSONDecodable
    {
        let field:JSON.FieldDecoder<Never?> = .init(key: nil,
            value: .number(.init(value)))

        #expect(throws: JSON.DecodingError<Never?>.self)
        {
            let _:Signed = try field.decode()
        }
    }
    private
    static func decode<Signed>(_ value:Int64, to:Signed.Type)
        where Signed:SignedInteger & JSONDecodable
    {
        let field:JSON.FieldDecoder<Never?> = .init(key: nil,
            value: .number(.init(value)))

        #expect(throws: Never.self)
        {
            let _:Signed = try field.decode()
        }
    }

    private
    static func expect<Unsigned>(_ value:UInt64, overflows:Unsigned.Type)
        where Unsigned:UnsignedInteger & JSONDecodable
    {
        let field:JSON.FieldDecoder<Never?> = .init(key: nil,
            value: .number(.init(value)))

        #expect(throws: JSON.DecodingError<Never?>.self)
        {
            let _:Unsigned = try field.decode()
        }
    }
    private
    static func decode<Unsigned>(_ value:UInt64, to:Unsigned.Type)
        where Unsigned:UnsignedInteger & JSONDecodable
    {
        let field:JSON.FieldDecoder<Never?> = .init(key: nil,
            value: .number(.init(value)))

        #expect(throws: Never.self)
        {
            let _:Unsigned = try field.decode()
        }
    }
}
