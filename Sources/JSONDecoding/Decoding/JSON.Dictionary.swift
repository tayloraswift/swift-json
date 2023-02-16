extension JSON
{
    /// A thin wrapper around a native Swift dictionary providing an efficient decoding
    /// interface for a JSON object.
    @frozen public
    struct Dictionary
    {
        public
        var items:[String: JSON]
        
        @inlinable public
        init(_ items:[String: JSON] = [:])
        {
            self.items = items
        }
    }
}
extension JSON.Dictionary
{
    @inlinable public
    init(object:[(key:String, value:JSON)]) throws
    {
        self.init(.init(minimumCapacity: object.count))
        for (key, value):(String, JSON) in object
        {
            if case _? = self.items.updateValue(value, forKey: key)
            {
                throw JSON.DictionaryKeyError.duplicate(key)
            }
        }
    }
}
extension JSON.Dictionary
{
    @inlinable public
    subscript(key:String) -> JSON.ExplicitField<String>?
    {
        self.items[key].map { .init(key: key, value: $0) }
    }
    @inlinable public
    subscript(key:String) -> JSON.ImplicitField
    {
        .init(key: key, value: self.items[key])
    }
}
