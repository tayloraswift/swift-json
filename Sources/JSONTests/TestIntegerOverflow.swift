import JSON
import Testing

struct IntegerOverflow
{
}
extension IntegerOverflow
{
    private
    func expect<Signed>(_ value:Int64, overflows:Signed.Type)
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
    func decode<Signed>(_ value:Int64, to:Signed.Type)
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
    func expect<Unsigned>(_ value:UInt64, overflows:Unsigned.Type)
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
    func decode<Unsigned>(_ value:UInt64, to:Unsigned.Type)
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
extension IntegerOverflow
{
    @Test("Int8")
    func int8()
    {
        self.expect(256, overflows: Int8.self)
    }

    @Test("Int16")
    func int16()
    {
        self.decode(256, to: Int16.self)
    }

    @Test("Int32")
    func int32()
    {
        self.decode(256, to: Int32.self)
    }

    @Test("Int64")
    func int64()
    {
        self.decode(256, to: Int64.self)
    }

    @Test("Int64.max")
    func int64max()
    {
        self.decode(Int64.max, to: Int64.self)
    }

    @Test("Int64.min")
    func int64min()
    {
        self.decode(Int64.min, to: Int64.self)
    }

    @Test("Int")
    func int()
    {
        self.decode(256, to: Int.self)
    }

    @Test("UInt8")
    func uint8()
    {
        self.expect(256, overflows: UInt8.self)
    }

    @Test("UInt16")
    func uint16()
    {
        self.decode(256, to: UInt16.self)
    }

    @Test("UInt32")
    func uint32()
    {
        self.decode(256, to: UInt32.self)
    }

    @Test("UInt64")
    func uint64()
    {
        self.decode(256, to: UInt64.self)
    }

    @Test("UInt64.max")
    func uint64max()
    {
        self.decode(UInt64.max, to: UInt64.self)
    }

    @Test("UInt")
    func uint()
    {
        self.decode(256, to: UInt.self)
    }
}

