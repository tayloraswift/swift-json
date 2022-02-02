extension Unicode.ASCII 
{
    struct StartOfHeader:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x01)
    }
    
    struct Colon:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x3a)
    }
    struct Equals:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x3d)
    }
    struct Minus:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x2d)
    }
    struct Period:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x2e)
    }
    struct Quote:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x22)
    }
    struct Space:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x20)
    }
    
    struct Zero:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x30)
    }
    struct One:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x31)
    }
    struct Two:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x32)
    }
    struct Three:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x33)
    }
    struct Four:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x34)
    }
    struct Five:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x35)
    }
    struct Six:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x36)
    }
    struct Seven:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x37)
    }
    struct Eight:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x38)
    }
    struct Nine:Grammar.TerminalSequence
    {
        typealias Terminal  =                 UInt8
        typealias Terminals = CollectionOfOne<UInt8>
        static 
        let terminals:CollectionOfOne<UInt8> = .init(0x39)
    }
    
    typealias Hyphen = Minus
    
    struct Digit:Grammar.TerminalClass 
    {
        typealias Terminal      = UInt8
        typealias Production    = Int 
        
        let production:Int 
        
        init?(terminal codepoint:UInt8)
        {
            guard 0x30 ... 0x39 ~= codepoint 
            else 
            {
                return nil 
            }
            self.production = .init(codepoint - 0x30)
        }
        var terminal:UInt8 
        {
            UInt8.init(self.production) + 0x30
        }
    }
}
