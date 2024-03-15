import JSONAST

extension JSON.ArrayEncoder
{
    /// A syntactical abstraction used to express the “end index” of an array. This type has no
    /// inhabitants.
    @frozen public
    enum Index
    {
    }
}
extension JSON.ArrayEncoder.Index
{
    /// A syntactical symbol used to express the “end index” of an array.
    @inlinable public static prefix
    func + (_:Self)
    {
    }
}
