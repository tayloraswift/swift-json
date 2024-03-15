extension JSON
{
    /// A decoder failed to cast a variant to an expected value type.
    @frozen public
    enum TypecastError<Value>:Equatable, Error
    {
        case null
        case bool
        case number
        case string
        case array
        case object
    }
}
extension JSON.TypecastError
{
    @inlinable public
    init(invalid json:__shared JSON.Node)
    {
        switch json
        {
        case .null:     self = .null
        case .bool:     self = .bool
        case .number:   self = .number
        case .string:   self = .string
        case .array:    self = .array
        case .object:   self = .object
        }
    }
}
extension JSON.TypecastError:CustomStringConvertible
{
    private
    var type:String
    {
        switch self
        {
        case .null:     "null"
        case .bool:     "bool"
        case .number:   "number"
        case .string:   "string"
        case .array:    "array"
        case .object:   "object"
        }
    }
    public
    var description:String
    {
        "cannot cast variant of type '\(self.type)' to type '\(Value.self)'"
    }
}
