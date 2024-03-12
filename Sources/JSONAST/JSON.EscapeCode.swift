extension JSON
{
    @frozen @usableFromInline internal
    enum EscapeCode:Equatable, Hashable, Comparable, Sendable
    {
        case b
        case t
        case n
        case f
        case r
        case quote
        case backslash
    }
}
extension JSON.EscapeCode
{
    @inlinable internal
    init?(escaping codeunit:UInt8)
    {
        switch codeunit
        {
        case 0x08:  self = .b
        case 0x09:  self = .t
        case 0x0A:  self = .n
        case 0x0C:  self = .f
        case 0x0D:  self = .r
        case 0x22:  self = .quote
        case 0x5C:  self = .backslash
        default:    return nil
        }
    }

    @inlinable internal static
    func += (utf8:inout ArraySlice<UInt8>, self:Self)
    {
        utf8.append(0x5C) // '\'
        switch self
        {
        case .b:        utf8.append(0x62) // 'b'
        case .t:        utf8.append(0x74) // 't'
        case .n:        utf8.append(0x6E) // 'n'
        case .f:        utf8.append(0x66) // 'f'
        case .r:        utf8.append(0x72) // 'r'
        case .quote:    utf8.append(0x22) // '"'
        case .backslash:utf8.append(0x5C) // '\'
        }
    }
}
