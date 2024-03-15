#if (os(Linux) || os(macOS)) && arch(x86_64)
extension Float80:JSONDecodable
{
    @inlinable public
    init(json:JSON.Node) throws
    {
        self = try json.cast { $0.as(Self.self) }
    }
}
#endif
