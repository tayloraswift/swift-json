extension Unicode 
{
    enum Latin1
    {
    }
}
extension Unicode.Latin1 
{
    struct Printable:Grammar.TerminalClass
    {
        typealias Terminal = UInt8 
        
        let terminal:UInt8 
        
        init?(terminal codepoint:UInt8)
        {
            guard 0x20 ... 0x7e ~= codepoint || 0xa0 <= codepoint
            else 
            {
                return nil 
            }
            self.terminal = codepoint
        }
        
        var scalar:Unicode.Scalar 
        {
            .init(self.terminal)
        }
        var character:Character 
        {
            .init(self.scalar)
        }
        var production:Character 
        {
            self.character
        }
    }
}
