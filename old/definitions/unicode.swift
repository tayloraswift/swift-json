extension Character 
{
    struct Letter:Grammar.TerminalClass 
    {
        typealias Terminal = Character 
        
        let production:Character 
        
        init?(terminal character:Character)
        {
            guard character.isLetter
            else 
            {
                return nil 
            }
            self.production = character
        }
    }
    
    enum E 
    {
        struct Anycase:Grammar.TerminalClass 
        {
            typealias Terminal = Character
            init?(terminal character:Character)
            {
                switch character 
                {
                case "e", "E":
                    return 
                default:
                    return nil
                }
            }
            var terminal:Character
            {
                "e"
            }
            var production:Void 
            {
                ()
            }
        }
    }
    
    struct AngleLeft:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("<")
    }
    struct AngleRight:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init(">")
    }
    
    struct Backslash:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("\\")
    }
    struct BracketLeft:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("[")
    }
    struct BracketRight:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("]")
    }
    struct Bracketed<Expression>:Grammar.BracketedExpression 
        where Expression:Grammar.Parsable, Expression.Terminal == Character
    {
        typealias Terminal  = Character
        typealias Start     = BracketLeft  
        typealias End       = BracketRight
        
        let production:Expression.Production
    }
    
    struct And:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("&")
    }
    struct BraceLeft:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("{")
    }
    struct BraceRight:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("}")
    }
    struct Braced<Expression>:Grammar.BracketedExpression 
        where Expression:Grammar.Parsable, Expression.Terminal == Character
    {
        typealias Terminal  = Character
        typealias Start     = BraceLeft  
        typealias End       = BraceRight
        
        let production:Expression.Production
    }
    
    struct Colon:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init(":")
    }
    struct Comma:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init(",")
    }
    struct Minus:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("-")
    }
    
    struct ParenthesisLeft:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("(")
    }
    struct ParenthesisRight:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init(")")
    }
    struct Parenthesized<Expression>:Grammar.BracketedExpression 
        where Expression:Grammar.Parsable, Expression.Terminal == Character
    {
        typealias Terminal  = Character
        typealias Start     = ParenthesisLeft 
        typealias End       = ParenthesisRight
        
        let production:Expression.Production
    }
    
    struct Percent:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("%")
    }
    struct Period:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init(".")
    }
    struct Plus:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("+")
    }
    struct Quote:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("\"")
    }
    struct Slash:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("/")
    }
    struct Zero:Grammar.TerminalSequence
    {
        typealias Terminal  =                 Character
        typealias Terminals = CollectionOfOne<Character> 
        static 
        let terminals:CollectionOfOne<Character> = .init("0")
    }
    
    typealias Hyphen = Minus
    
    struct Whitespace:Grammar.TerminalClass 
    {
        typealias Terminal      = Character
        typealias Production    = Void
        
        var production:Void 
        {
            ()
        }
        init?(terminal character:Character)
        {
            guard character.isWhitespace 
            else 
            {
                return nil
            }
        }
        var terminal:Character 
        {
            " "
        }
    }
    struct Digit:Grammar.TerminalClass
    {
        typealias Terminal      = Character
        typealias Production    = Int 
        
        let production:Int 
        
        init?(terminal character:Character)
        {
            switch character 
            {
            case "0":   self.production = 0
            case "1":   self.production = 1
            case "2":   self.production = 2
            case "3":   self.production = 3
            case "4":   self.production = 4
            case "5":   self.production = 5
            case "6":   self.production = 6
            case "7":   self.production = 7
            case "8":   self.production = 8
            case "9":   self.production = 9
            default:    return nil
            }
        }
        var terminal:Character 
        {
            Character.init(Unicode.Scalar.init(0x30 + UInt8.init(self.production)))
        }
    }
    enum HexDigit 
    {
        private static 
        subscript(lowercasing value:Int) -> Character 
        {
            let remainder:UInt8 = .init(value)
            return Character.init(Unicode.Scalar.init((remainder < 10 ? 0x30 : 0x57) &+ remainder))
        }
        struct Lowercase:Grammar.TerminalClass
        {
            typealias Terminal      = Character
            typealias Production    = Int 
            
            let production:Int 
            
            init?(terminal character:Character)
            {
                // 0-9 will return false for isLowercase
                if let value:Int    = character.hexDigitValue, !character.isUppercase
                {
                    self.production = value 
                }
                else 
                {
                    return nil
                }
            }
            var terminal:Character 
            {
                HexDigit[lowercasing: self.production]
            }
        }
        struct Anycase:Grammar.TerminalClass
        {
            typealias Terminal      = Character
            typealias Production    = Int 
            
            let production:Int 
            
            init?(terminal character:Character)
            {
                if let value:Int    = character.hexDigitValue 
                {
                    self.production = value 
                }
                else 
                {
                    return nil
                }
            }
            var terminal:Character 
            {
                HexDigit[lowercasing: self.production]
            }
        }
    }
}
