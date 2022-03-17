import Grammar

@main
enum Perf 
{
    static 
    func main() throws 
    {
        let test:String = try File.read(from: "perf.txt")
        
        do 
        {
            let samples:[(process:Process, sample:Sample)] = 
            try Grammar.parse(diagnosing: test.unicodeScalars, as: Rule<String.Index>.SampleVector.self)
            print(samples.count)
        }
        catch let error as ParsingError<String.Index> 
        {
            print(error.annotate(source: test, line: { String.init($0.map{ $0 == "\t" ? " " : $0 }) }, 
                newline: \.isNewline))
        }
        catch let error 
        {
            print(error)
        }
    }
    
    struct Process:Identifiable
    {
        let id:UInt 
        let command:String 
    }
    enum Convention 
    {
        case c 
        case swift 
    }
    enum Module 
    {
        case kernel 
        case inlined 
        case binary([String])
    }
    struct Sample 
    {
        struct Frame 
        {
            let symbol:(description:String, convention:Convention)?
            let module:Module?
        }
        
        let period:Int
        let trace:[Frame]
    }
    enum Rule<Location>
    {
        typealias Codepoint = Grammar.Encoding<Location, Unicode.Scalar>
        typealias Digit<T>  = Grammar.Digit<Location, Unicode.Scalar, T> where T:BinaryInteger
    }
}
extension Perf.Rule 
{
    enum Keyword 
    {
        enum Cycles:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["c", "y", "c", "l", "e", "s"] }
        }
        enum Inlined:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["i", "n", "l", "i", "n", "e", "d"] }
        }
        enum KernelKallsyms:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["k", "e", "r", "n", "e", "l", ".", "k", "a", "l", "l", "s", "y", "m", "s"] }
        }
        enum Unknown:Grammar.TerminalSequence 
        {
            typealias Terminal = Unicode.Scalar 
            static 
            var literal:[Unicode.Scalar] { ["u", "n", "k", "n", "o", "w", "n"] }
        }
    }
    enum Whitespace:ParsingRule 
    {
        enum Element:Grammar.TerminalClass 
        {
            typealias Terminal      = Unicode.Scalar
            typealias Construction  = Void 
            static 
            func parse(terminal:Unicode.Scalar) -> Void? 
            {
                switch terminal 
                {
                case " ", "\t": return ()
                default:        return nil
                }
            }
        }
        
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Void
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            try input.parse(as: Element.self)
            input.parse(as: Element.self, in: Void.self)
        }
    }
    enum AbsolutePath:ParsingRule
    {
        enum Component:ParsingRule 
        {
            private 
            enum Element:ParsingRule 
            {
                private 
                enum Escaped:Grammar.TerminalClass 
                {
                    typealias Terminal      = Unicode.Scalar
                    typealias Construction  = Unicode.Scalar 
                    static 
                    func parse(terminal:Unicode.Scalar) -> Unicode.Scalar? 
                    {
                        terminal
                    }
                }
                private 
                enum Unescaped:Grammar.TerminalClass
                {
                    typealias Terminal      = Unicode.Scalar
                    typealias Construction  = Unicode.Scalar 
                    static 
                    func parse(terminal:Unicode.Scalar) -> Unicode.Scalar? 
                    {
                        switch terminal 
                        {
                        case "(", ")", "/", "\\":
                            return nil  
                        default:
                            return terminal
                        }
                    }
                } 
                
                typealias Terminal = Unicode.Scalar
                static 
                func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Character
                    where   Diagnostics:ParsingDiagnostics,
                            Diagnostics.Source.Index == Location,
                            Diagnostics.Source.Element == Terminal
                {
                    if let scalar:Unicode.Scalar = input.parse(as: Unescaped?.self) 
                    {
                        return Character.init(scalar)
                    }
                    let (_, scalar):(Void, Unicode.Scalar) = 
                        try input.parse(as: (Codepoint.Backslash, Escaped).self)
                    return Character.init(scalar)
                }
            }
            
            typealias Terminal = Unicode.Scalar
            static 
            func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> String
                where   Diagnostics:ParsingDiagnostics,
                        Diagnostics.Source.Index == Location,
                        Diagnostics.Source.Element == Terminal
            {
                try input.parse(as: Codepoint.Slash.self)
                return input.parse(as: Element.self, in: String.self)
            }
        }
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> [String]
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            try input.parse(as: Grammar.Reduce<Component, [String]>.self).compactMap { $0 }
        }
    }
    enum Module:ParsingRule
    {
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Perf.Module
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            let module:Perf.Module 
            try input.parse(as: Codepoint.ParenthesisLeft.self)
            if let _:Void = input.parse(as: Codepoint.BracketLeft?.self)
            {
                try input.parse(as: Keyword.KernelKallsyms.self)
                try input.parse(as: Codepoint.BracketRight.self)
                module = .kernel 
            }
            else if let _:Void = input.parse(as: Keyword.Inlined?.self)
            {
                module = .inlined 
            }
            else 
            {
                module = .binary(try input.parse(as: AbsolutePath.self))
            }
            try input.parse(as: Codepoint.ParenthesisRight.self)
            return module 
        }
    }
    enum Identifier:ParsingRule 
    {
        enum Head:Grammar.TerminalClass 
        {
            typealias Terminal      = Unicode.Scalar
            typealias Construction  = Character 
            static 
            func parse(terminal:Unicode.Scalar) -> Character? 
            {
                switch terminal 
                {
                case    "a" ... "z", 
                        "A" ... "Z",
                        "_", 
                        
                        "\u{00A8}", "\u{00AA}", "\u{00AD}", "\u{00AF}", 
                        "\u{00B2}" ... "\u{00B5}", "\u{00B7}" ... "\u{00BA}",
                        
                        "\u{00BC}" ... "\u{00BE}", "\u{00C0}" ... "\u{00D6}", 
                        "\u{00D8}" ... "\u{00F6}", "\u{00F8}" ... "\u{00FF}",
                        
                        "\u{0100}" ... "\u{02FF}", "\u{0370}" ... "\u{167F}", "\u{1681}" ... "\u{180D}", "\u{180F}" ... "\u{1DBF}", 
                        
                        "\u{1E00}" ... "\u{1FFF}", 
                        
                        "\u{200B}" ... "\u{200D}", "\u{202A}" ... "\u{202E}", "\u{203F}" ... "\u{2040}", "\u{2054}", "\u{2060}" ... "\u{206F}",
                        
                        "\u{2070}" ... "\u{20CF}", "\u{2100}" ... "\u{218F}", "\u{2460}" ... "\u{24FF}", "\u{2776}" ... "\u{2793}",
                        
                        "\u{2C00}" ... "\u{2DFF}", "\u{2E80}" ... "\u{2FFF}",
                        
                        "\u{3004}" ... "\u{3007}", "\u{3021}" ... "\u{302F}", "\u{3031}" ... "\u{303F}", "\u{3040}" ... "\u{D7FF}",
                        
                        "\u{F900}" ... "\u{FD3D}", "\u{FD40}" ... "\u{FDCF}", "\u{FDF0}" ... "\u{FE1F}", "\u{FE30}" ... "\u{FE44}", 
                        
                        "\u{FE47}" ... "\u{FFFD}", 
                        
                        "\u{10000}" ... "\u{1FFFD}", "\u{20000}" ... "\u{2FFFD}", "\u{30000}" ... "\u{3FFFD}", "\u{40000}" ... "\u{4FFFD}", 
                        
                        "\u{50000}" ... "\u{5FFFD}", "\u{60000}" ... "\u{6FFFD}", "\u{70000}" ... "\u{7FFFD}", "\u{80000}" ... "\u{8FFFD}", 
                        
                        "\u{90000}" ... "\u{9FFFD}", "\u{A0000}" ... "\u{AFFFD}", "\u{B0000}" ... "\u{BFFFD}", "\u{C0000}" ... "\u{CFFFD}", 
                        
                        "\u{D0000}" ... "\u{DFFFD}", "\u{E0000}" ... "\u{EFFFD}"
                        :
                    return .init(terminal)
                default:
                    return nil
                }
            }
        }
        enum Next:Grammar.TerminalClass 
        {
            typealias Terminal      = Unicode.Scalar
            typealias Construction  = Character 
            static 
            func parse(terminal:Unicode.Scalar) -> Character? 
            {
                if let character:Character = Head.parse(terminal: terminal) 
                {
                    return character
                }
                switch terminal 
                {
                case    "0" ... "9", 
                        "\u{0300}" ... "\u{036F}", 
                        "\u{1DC0}" ... "\u{1DFF}", 
                        "\u{20D0}" ... "\u{20FF}", 
                        "\u{FE20}" ... "\u{FE2F}":
                    return .init(terminal)
                default:
                    return nil
                }
            }
        }
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> String
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            var string:String = .init(try input.parse(as: Head.self))
            while let next:Character = input.parse(as: Next?.self)
            {
                string.append(next)
            }
            return string 
        }
    }
    enum Symbol:ParsingRule 
    {
        enum Offset:ParsingRule 
        {
            typealias Terminal = Unicode.Scalar
            static 
            func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> UInt
                where   Diagnostics:ParsingDiagnostics,
                        Diagnostics.Source.Index == Location,
                        Diagnostics.Source.Element == Terminal
            {
                try input.parse(as: Codepoint.Plus.self)
                try input.parse(as: Codepoint.Zero.self)
                try input.parse(as: Codepoint.X.Lowercase.self)
                return try input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<UInt>.Hex.Anycase>.self)
            }
        }
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) 
            throws -> (description:String, convention:Perf.Convention)?
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            let convention:Perf.Convention, 
                description:String 
            if let _:Void = input.parse(as: Codepoint.Dollar?.self)
            {
                // swift symbol 
                convention  = .swift
                description = Demangle["$\(try input.parse(as: Identifier.self))"]
                let _:UInt? = input.parse(as: Offset?.self)
            }
            else if let _:(Void, Void, Void) = 
                try? input.parse(as: (Codepoint.BracketLeft, Keyword.Unknown, Codepoint.BracketRight).self)
            {
                return nil
            }
            else 
            {
                convention  = .c
                description = try input.parse(as: Identifier.self)
                let _:UInt? = input.parse(as: Offset?.self)
            }
            return (description, convention)
        }
    }
    enum Sample:ParsingRule 
    {
        enum Frame:ParsingRule 
        {
            typealias Terminal = Unicode.Scalar
            static 
            func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> Perf.Sample.Frame
                where   Diagnostics:ParsingDiagnostics,
                        Diagnostics.Source.Index == Location,
                        Diagnostics.Source.Element == Terminal
            {
                let _:UInt = 
                    try input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<UInt>.Hex.Anycase>.self)
                try input.parse(as: Whitespace.self)
                let symbol:(description:String, convention:Perf.Convention)? = 
                    try input.parse(as: Symbol.self)
                try input.parse(as: Whitespace.self)
                let module:Perf.Module? = 
                    try input.parse(as: Module.self)
                return .init(symbol: symbol, module: module)
            }
        }
        
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) throws -> (process:Perf.Process, sample:Perf.Sample)
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            let command:String = 
                try input.parse(as: Identifier.self)
            let (_, process):(Void, UInt) = 
                try input.parse(as: (Whitespace,    Grammar.UnsignedIntegerLiteral<Digit<UInt>.Decimal>).self)
            
            let _:(Void, UInt)? = try? input.parse(as:    (Whitespace,    Grammar.UnsignedIntegerLiteral<Digit<UInt>.Decimal>).self)
            let _:(Void, UInt)? = try? input.parse(as: (Codepoint.Period, Grammar.UnsignedIntegerLiteral<Digit<UInt>.Decimal>).self)
            
            try input.parse(as: Grammar.Pad<Codepoint.Colon, Whitespace.Element>.self)
            let period:Int = 
                try input.parse(as: Grammar.UnsignedIntegerLiteral<Digit<Int>.Decimal>.self)
            try input.parse(as: (Whitespace, Keyword.Cycles).self)
            try input.parse(as: Grammar.Pad<Codepoint.Colon, Whitespace.Element>.self)
            
            var trace:[Perf.Sample.Frame] = []
            while let _:Void = input.parse(as: Codepoint.Newline?.self)
            {
                input.parse(as: Whitespace.Element.self, in: Void.self)
                guard let frame:Perf.Sample.Frame = input.parse(as: Frame?.self)
                else 
                {
                    break 
                }
                trace.append(frame)
            }
            return (.init(id: process, command: command), .init(period: period, trace: trace))
        }
    }
    enum SampleVector:ParsingRule 
    {
        typealias Terminal = Unicode.Scalar
        static 
        func parse<Diagnostics>(_ input:inout ParsingInput<Diagnostics>) 
            throws -> [(process:Perf.Process, sample:Perf.Sample)]
            where   Diagnostics:ParsingDiagnostics,
                    Diagnostics.Source.Index == Location,
                    Diagnostics.Source.Element == Terminal
        {
            var samples:[(process:Perf.Process, sample:Perf.Sample)]    = []
            input.parse(as: Codepoint.Whitespace.self, in: Void.self)
            while let (process, sample):(Perf.Process, Perf.Sample)     = input.parse(as: Sample?.self)
            {
                samples.append((process, sample))
                input.parse(as: Codepoint.Whitespace.self, in: Void.self)
            }
            return samples
        }
    }
}
