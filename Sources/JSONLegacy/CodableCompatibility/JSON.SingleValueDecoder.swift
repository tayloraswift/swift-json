import JSONDecoding

extension JSON
{
    /// A single-value decoding container, for use with compiler-generated ``Decodable``
    /// implementations.
    public
    struct SingleValueDecoder
    {
        let value:JSON.Node
        public
        let codingPath:[any CodingKey]
        public
        let userInfo:[CodingUserInfoKey: Any]

        public
        init(_ value:JSON.Node, path:[any CodingKey],
            userInfo:[CodingUserInfoKey: Any] = [:])
        {
            self.value = value
            self.codingPath = path
            self.userInfo = userInfo
        }
    }
}
extension JSON.SingleValueDecoder
{
    func diagnose<T>(_ decode:(JSON.Node) throws -> T?) throws -> T
    {
        do
        {
            if let decoded:T = try decode(value)
            {
                return decoded
            }

            throw DecodingError.init(annotating: JSON.TypecastError<T>.init(invalid: value),
                initializing: T.self,
                path: self.codingPath)
        }
        catch let error
        {
            throw DecodingError.init(annotating: error,
                initializing: T.self,
                path: self.codingPath)
        }
    }
}
extension JSON.SingleValueDecoder:Decoder
{
    public
    func singleValueContainer() -> any SingleValueDecodingContainer
    {
        self as any SingleValueDecodingContainer
    }
    public
    func unkeyedContainer() throws -> any UnkeyedDecodingContainer
    {
        JSON.UnkeyedDecoder.init(try self.diagnose(\.array),
            path: self.codingPath) as any UnkeyedDecodingContainer
    }
    public
    func container<Key>(keyedBy _:Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key:CodingKey
    {
        let container:JSON.KeyedDecoder<Key> =
            .init(try .init(indexing: try self.diagnose(\.object)), path: self.codingPath)
        return .init(container)
    }
}

extension JSON.SingleValueDecoder:SingleValueDecodingContainer
{
    public
    func decode<T>(_:T.Type) throws -> T where T:Decodable
    {
        try .init(from: self)
    }
    public
    func decodeNil() -> Bool
    {
        self.value.as(Never?.self) != nil
    }
    public
    func decode(_:Bool.Type) throws -> Bool
    {
        try self.diagnose { $0.as(Bool.self) }
    }
    public
    func decode(_:Float.Type) throws -> Float
    {
        try self.diagnose { $0.as(Float.self) }
    }
    public
    func decode(_:Double.Type) throws -> Double
    {
        try self.diagnose { $0.as(Double.self) }
    }
    public
    func decode(_:String.Type) throws -> String
    {
        try self.diagnose { $0.as(String.self) }
    }
    public
    func decode(_:Int.Type) throws -> Int
    {
        try self.diagnose { try $0.as(Int.self) }
    }
    public
    func decode(_:Int64.Type) throws -> Int64
    {
        try self.diagnose { try $0.as(Int64.self) }
    }
    public
    func decode(_:Int32.Type) throws -> Int32
    {
        try self.diagnose { try $0.as(Int32.self) }
    }
    public
    func decode(_:Int16.Type) throws -> Int16
    {
        try self.diagnose { try $0.as(Int16.self) }
    }
    public
    func decode(_:Int8.Type) throws -> Int8
    {
        try self.diagnose { try $0.as(Int8.self) }
    }
    public
    func decode(_:UInt.Type) throws -> UInt
    {
        try self.diagnose { try $0.as(UInt.self) }
    }
    public
    func decode(_:UInt64.Type) throws -> UInt64
    {
        try self.diagnose { try $0.as(UInt64.self) }
    }
    public
    func decode(_:UInt32.Type) throws -> UInt32
    {
        try self.diagnose { try $0.as(UInt32.self) }
    }
    public
    func decode(_:UInt16.Type) throws -> UInt16
    {
        try self.diagnose { try $0.as(UInt16.self) }
    }
    public
    func decode(_:UInt8.Type) throws -> UInt8
    {
        try self.diagnose { try $0.as(UInt8.self) }
    }
}
