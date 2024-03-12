import JSONAST

extension JSON
{
    @usableFromInline
    protocol InlineEncoder
    {
        static
        func move(_ json:inout JSON) -> Self

        mutating
        func move() -> JSON
    }
}
extension JSON.InlineEncoder
{
    @inlinable static
    var empty:Self
    {
        var json:JSON = .init(utf8: [])
        return .move(&json)
    }
}
