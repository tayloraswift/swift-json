// parsing // 
extension Grammar 
{
    typealias Parsable = _GrammarParsable
}
protocol _GrammarParsable 
{
    associatedtype Terminal 
    associatedtype Production = Self
    
    init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
    var production:Production
    {
        get 
    }
}
extension Grammar.Parsable where Production == Self 
{
    init(production:Production) 
    {
        self = production
    }
    var production:Production 
    {
        self 
    }
}

extension Grammar 
{
    enum Rule 
    {
        case parser(Any.Type)
        case literal(file:StaticString, line:Int)
    }
    
    struct ParsingError<Source>:TraceableError, CustomStringConvertible where Source:Collection
    {
        static 
        var namespace:String 
        {
            "parsing error"
        }
        let problem:Error, 
            source:Source, 
            index:Source.Index,
            trace:[(index:Source.Index, rule:Rule, type:Any.Type)]
        
        init(at index:Source.Index, in source:Source, because problem:Error, 
            trace:[(index:Source.Index, rule:Rule, type:Any.Type)])
        {
            self.problem    = problem
            self.source     = source 
            self.index      = index 
            self.trace      = trace
        }

        var context:[String] 
        {
            [ "while parsing input sequence '\(self.source)'" ]
            +
            trace.map 
            {
                switch ($0.rule, $0.type) 
                {
                case (.literal(file: let file, line: let line), _):
                    return "while parsing productionless rule (literal sequence at \(file):\(line))"
                case (.parser(let parser), is Void.Type):
                    return "while parsing productionless rule '\(parser)'"
                case (.parser(let parser), let type):
                    return "while parsing value of type '\(type)' by rule '\(parser)'"
                }
            }
        } 
        var next:Error? 
        {
            self.problem 
        }
    }
    
    struct Input<Source> where Source:Collection 
    {
        private 
        let source:Source
        private(set)
        var index:Source.Index 
        
        private 
        var stack:[(index:Source.Index, rule:Rule, type:Any.Type)], 
            frontier:ParsingError<Source>?
        
        init(_ source:Source)
        {
            self.source     = source 
            self.index      = source.startIndex 
            self.stack      = []
            self.frontier   = nil 
        }
        
        subscript(_ index:Source.Index) -> Source.Element 
        {
            self.source[index]
        }
        subscript<Indices>(_ range:Indices) -> Source.SubSequence 
            where Indices:RangeExpression, Indices.Bound == Source.Index 
        {
            self.source[range.relative(to: self.source)]
        }
        
        fileprivate mutating 
        func next() -> Source.Element?
        {
            guard self.index != self.source.endIndex
            else 
            {
                return nil 
            }
            defer 
            {
                self.index = self.source.index(after: self.index)
            }
            return self.source[self.index]
        }

        private mutating 
        func group<Parser, T>(parser:Parser.Type, _ body:(inout Self) throws -> T) throws -> T
        {
            try self.group(rule: .parser(parser), body)
        }
        private mutating 
        func group<T>(file:StaticString, line:Int, _ body:(inout Self) throws -> T) throws -> T
        {
            try self.group(rule: .literal(file: file, line: line), body)
        }
        private mutating 
        func group<T>(rule:Rule, _ body:(inout Self) throws -> T) throws -> T
        {
            self.stack.append((self.index, rule, T.self))
            
            do 
            {
                let parsed:T = try body(&self)
                self.stack.removeLast()
                return parsed 
            }
            catch let diagnostic as ParsingError<Source> 
            {
                self.index = self.stack.removeLast().index 
                throw diagnostic
            }
            catch let error 
            {
                let diagnostic:ParsingError<Source>
                if  let frontier:ParsingError<Source>   = self.frontier, 
                        self.index < frontier.index
                {
                    // we did not make it as far as the previous most-successful parse 
                    diagnostic      = frontier 
                }
                else 
                {
                    diagnostic      = .init(at: self.index, in: self.source, because: error, trace: self.stack) 
                    self.frontier   = diagnostic 
                }
                self.index = self.stack.removeLast().index 
                throw diagnostic
            }
        }
        
        mutating 
        func parse(prefix count:Int) throws -> Source.SubSequence
        {
            guard let index:Source.Index = 
                self.source.index(self.index, offsetBy: count, limitedBy: self.source.endIndex)
            else 
            {
                throw Expected<Any, Source.Element>.init(encountered: nil)
            }
            
            let prefix:Source.SubSequence = self.source[self.index ..< index]
            self.index = index 
            return prefix
        }
        
        mutating 
        func parse<T>(_:T.Type) throws -> T
            where   T:Parsable, T.Terminal == Source.Element
        {
            try self.group(parser: T.self, T.init(parsing:))
        }
        
        mutating 
        func parse<T>(as parser:T.Type) throws -> T.Production 
            where   T:Parsable, T.Terminal == Source.Element
        {
            try self.group(parser: parser){ try T.init(parsing: &$0).production }
        }
        @discardableResult 
        mutating 
        func parse<T0, T1>(as parser:(T0, T1).Type) throws 
            -> (T0.Production, T1.Production) 
            where   T0:Parsable, T0.Terminal == Source.Element, 
                    T1:Parsable, T1.Terminal == Source.Element 
        {
            try self.group(parser: parser)
            {
                let list:(T0.Production, T1.Production) 
                list.0 = try T0.init(parsing: &$0).production
                list.1 = try T1.init(parsing: &$0).production
                return list
            }
        }
        @discardableResult 
        mutating 
        func parse<T0, T1, T2>(as parser:(T0, T1, T2).Type) throws 
            -> (T0.Production, T1.Production, T2.Production) 
            where   T0:Parsable, T0.Terminal == Source.Element, 
                    T1:Parsable, T1.Terminal == Source.Element,
                    T2:Parsable, T2.Terminal == Source.Element 
        {
            try self.group(parser: parser)
            {
                let list:(T0.Production, T1.Production, T2.Production) 
                list.0 = try T0.init(parsing: &$0).production
                list.1 = try T1.init(parsing: &$0).production
                list.2 = try T2.init(parsing: &$0).production
                return list
            }
        }
        @discardableResult 
        mutating 
        func parse<T0, T1, T2, T3>(as parser:(T0, T1, T2, T3).Type) throws 
            -> (T0.Production, T1.Production, T2.Production, T3.Production) 
            where   T0:Parsable, T0.Terminal == Source.Element, 
                    T1:Parsable, T1.Terminal == Source.Element,
                    T2:Parsable, T2.Terminal == Source.Element,
                    T3:Parsable, T3.Terminal == Source.Element 
        {
            try self.group(parser: parser)
            {
                let list:(T0.Production, T1.Production, T2.Production, T3.Production) 
                list.0 = try T0.init(parsing: &$0).production
                list.1 = try T1.init(parsing: &$0).production
                list.2 = try T2.init(parsing: &$0).production
                list.3 = try T3.init(parsing: &$0).production
                return list
            }
        }
        @discardableResult 
        mutating 
        func parse<T0, T1, T2, T3, T4>(as parser:(T0, T1, T2, T3, T4).Type) throws 
            -> (T0.Production, T1.Production, T2.Production, T3.Production, T4.Production) 
            where   T0:Parsable, T0.Terminal == Source.Element, 
                    T1:Parsable, T1.Terminal == Source.Element,
                    T2:Parsable, T2.Terminal == Source.Element,
                    T3:Parsable, T3.Terminal == Source.Element,
                    T4:Parsable, T4.Terminal == Source.Element 
        {
            try self.group(parser: parser)
            {
                let list:(T0.Production, T1.Production, T2.Production, T3.Production, T4.Production) 
                list.0 = try T0.init(parsing: &$0).production
                list.1 = try T1.init(parsing: &$0).production
                list.2 = try T2.init(parsing: &$0).production
                list.3 = try T3.init(parsing: &$0).production
                list.4 = try T4.init(parsing: &$0).production
                return list
            }
        }
        @discardableResult 
        mutating 
        func parse<T0, T1, T2, T3, T4, T5>(as parser:(T0, T1, T2, T3, T4, T5).Type) throws 
            -> (T0.Production, T1.Production, T2.Production, T3.Production, T4.Production, T5.Production) 
            where   T0:Parsable, T0.Terminal == Source.Element, 
                    T1:Parsable, T1.Terminal == Source.Element,
                    T2:Parsable, T2.Terminal == Source.Element,
                    T3:Parsable, T3.Terminal == Source.Element,
                    T4:Parsable, T4.Terminal == Source.Element,
                    T5:Parsable, T5.Terminal == Source.Element 
        {
            try self.group(parser: parser)
            {
                let list:(T0.Production, T1.Production, T2.Production, T3.Production, T4.Production, T5.Production) 
                list.0 = try T0.init(parsing: &$0).production
                list.1 = try T1.init(parsing: &$0).production
                list.2 = try T2.init(parsing: &$0).production
                list.3 = try T3.init(parsing: &$0).production
                list.4 = try T4.init(parsing: &$0).production
                list.5 = try T5.init(parsing: &$0).production
                return list
            }
        }
        @discardableResult 
        mutating 
        func parse<T0, T1, T2, T3, T4, T5, T6>(as parser:(T0, T1, T2, T3, T4, T5, T6).Type) throws 
            -> (T0.Production, T1.Production, T2.Production, T3.Production, T4.Production, T5.Production, T6.Production) 
            where   T0:Parsable, T0.Terminal == Source.Element, 
                    T1:Parsable, T1.Terminal == Source.Element,
                    T2:Parsable, T2.Terminal == Source.Element,
                    T3:Parsable, T3.Terminal == Source.Element,
                    T4:Parsable, T4.Terminal == Source.Element,
                    T5:Parsable, T5.Terminal == Source.Element,
                    T6:Parsable, T6.Terminal == Source.Element 
        {
            try self.group(parser: parser)
            {
                let list:(T0.Production, T1.Production, T2.Production, T3.Production, T4.Production, T5.Production, T6.Production) 
                list.0 = try T0.init(parsing: &$0).production
                list.1 = try T1.init(parsing: &$0).production
                list.2 = try T2.init(parsing: &$0).production
                list.3 = try T3.init(parsing: &$0).production
                list.4 = try T4.init(parsing: &$0).production
                list.5 = try T5.init(parsing: &$0).production
                list.6 = try T6.init(parsing: &$0).production
                return list
            }
        }
        
        mutating 
        func parse<T>(as _:T?.Type) -> T.Production? 
            where T:Parsable, T.Terminal == Source.Element
        {
            guard let value:T.Production    = try? self.parse(as: T.self)
            else 
            {
                return nil
            }
            return value 
        }
        mutating 
        func parse<T>(as _:T.Type, in _:Void.Type) 
            where T:Parsable, T.Terminal == Source.Element, T.Production == Void 
        {
            while let _:Void                = try? self.parse(as: T.self)
            {
            }
        }
        mutating 
        func parse<T, Productions>(as _:T.Type, in _:Productions.Type) -> Productions 
            where T:Parsable, T.Terminal == Source.Element, Productions:RangeReplaceableCollection, Productions.Element == T.Production
        {
            var productions:Productions     = .init()
            while let value:T.Production    = try? self.parse(as: T.self)
            {
                productions.append(value)
            }
            return productions
        }
    }
}
extension Grammar.Input where Source.Element:Equatable 
{
    mutating 
    func parse(terminal:Source.Element, file:StaticString = #filePath, line:Int = #line) throws 
    {
        try self.parse(terminals: CollectionOfOne<Source.Element>.init(terminal), file: file, line: line)
    }
    mutating 
    func parse<S>(terminals:S, file:StaticString = #filePath, line:Int = #line) throws 
        where S:Sequence, S.Element == Source.Element
    {
        try self.group(file: file, line: line) 
        {
            for expected:S.Element in terminals
            {
                guard let element:Source.Element = $0.next()
                else 
                {
                    throw Grammar.ExpectedTerminal<S.Element>.init(expected, encountered: nil)
                }
                guard element == expected 
                else 
                {
                    throw Grammar.ExpectedTerminal<S.Element>.init(expected, encountered: element)
                }
            }
        }
    }
}
extension Grammar 
{
    static 
    func parse<Source, T>(_ source:Source, as _:T.Type) throws -> T.Production
        where Source:Collection, T:Parsable, T.Terminal == Source.Element
    {
        var input:Input<Source>     = .init(source)
        let result:T.Production     =   try input.parse(as: T.self)
                                        try input.parse(as: EndOfStream<T.Terminal>.self)
        return result
    }
    static 
    func parse<Source, T, Productions>(_ source:Source, as _:T.Type, in _:Productions.Type) throws -> Productions
        where Source:Collection, T:Parsable, T.Terminal == Source.Element, Productions:RangeReplaceableCollection, Productions.Element == T.Production
    {
        var input:Input<Source>     = .init(source)
        let result:Productions      =       input.parse(as: T.self, in: Productions.self)
                                        try input.parse(as: EndOfStream<T.Terminal>.self)
        return result
    }
}

extension Optional:Grammar.Parsable where Wrapped:Grammar.Parsable 
{
    typealias Terminal = Wrapped.Terminal 
    
    var production:Wrapped.Production?
    {
        self?.production
    }
    init<C>(parsing input:inout Grammar.Input<C>) where C:Collection, C.Element == Terminal
    {
        self = try? input.parse(Wrapped.self)
    }
} 
extension Array:Grammar.Parsable where Element:Grammar.Parsable
{
    typealias Terminal = Element.Terminal 
    
    init<C>(parsing input:inout Grammar.Input<C>) where C:Collection, C.Element == Terminal
    {
        self.init()
        while let next:Element = try? input.parse(Element.self)
        {
            self.append(next)
        }
    }
}

// serialization // 
extension Grammar 
{
    typealias Serializable = _GrammarSerializable
}
protocol _GrammarSerializable 
{
    associatedtype Terminals where Terminals:Sequence  
    
    var serialized:Terminals 
    {
        get 
    }
}

// extras //
protocol _GrammarScanningError:Error 
{
    associatedtype Terminal 
    
    var encountered:Terminal?
    {
        get 
    }
}
extension Grammar.ScanningError 
{
    var isEndOfStreamError:Bool
    {
        self.encountered == nil 
    }
}
enum Grammar 
{
    typealias TerminalClass     = _GrammarTerminalClass
    typealias TerminalSequence  = _GrammarTerminalSequence
    
    typealias ScanningError     = _GrammarScanningError
    
    struct IntegerOverflowError<T>:Error, CustomStringConvertible 
    {
        var description:String 
        {
            "parsed value overflows interger type '\(T.self)'"
        }
    }
    struct ExpectedTerminal<Terminal>:ScanningError, CustomStringConvertible 
    {
        let terminal:Terminal
        let encountered:Terminal?
        
        init(_ terminal:Terminal, encountered:Terminal?)
        {
            self.terminal       = terminal
            self.encountered    = encountered
        }
        var description:String 
        {
            if let encountered:Terminal = self.encountered 
            {
                return "expected '\(self.terminal)' (encountered '\(encountered)')"
            }
            else 
            {
                return "expected '\(self.terminal)'"
            }    
        }
    }
    struct Expected<T, Terminal>:ScanningError, CustomStringConvertible 
    {
        let encountered:Terminal?
        
        init(encountered:Terminal?)
        {
            self.encountered = encountered
        }
        var description:String 
        {
            "expected value of type '\(T.self)'"
        }
    }
    struct Excluded<T, Exclusion>:Error, CustomStringConvertible 
    {
        var description:String 
        {
            "value of type '\(T.self)' would also be a valid value of '\(Exclusion.self)'"
        }
    }
}

protocol _GrammarTerminalClass:Grammar.Parsable, Grammar.Serializable
{
    init?(terminal:Terminal)
    var terminal:Terminal 
    {
        get 
    }
}
extension Grammar.TerminalClass 
{
    init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
    {
        guard let terminal:Terminal   = input.next()
        else 
        {
            throw Grammar.Expected<Self, Terminal>.init(encountered: nil)
        }
        guard let value:Self          = .init(terminal: terminal)
        else 
        {
            throw Grammar.Expected<Self, Terminal>.init(encountered: terminal)
        }
        self = value 
    }
    var serialized:CollectionOfOne<Terminal>  
    {
        .init(self.terminal)
    }
}
extension Grammar.TerminalClass where Production == Terminal 
{
    var terminal:Terminal 
    {
        self.production
    }
}

protocol _GrammarTerminalSequence:Grammar.Parsable, Grammar.Serializable
    where Terminals.Element == Terminal, Terminal:Equatable, Production == Void 
{    
    static 
    var terminals:Terminals
    {
        get 
    }
    init()
}
extension Grammar.TerminalSequence 
{
    init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
    {
        try input.parse(terminals: Self.terminals)
        self.init()
    }
    var production:Void 
    {
        ()
    }
    var serialized:Terminals 
    {
        Self.terminals
    }
}

protocol _GrammarBracketedExpression:Grammar.Parsable 
    where Production == Expression.Production
{
    associatedtype Start        where      Start:Grammar.Parsable,      Start.Terminal == Terminal,  Start.Production == Void
    associatedtype Expression   where Expression:Grammar.Parsable, Expression.Terminal == Terminal
    associatedtype End          where        End:Grammar.Parsable,        End.Terminal == Terminal,    End.Production == Void
    
    init(production:Production) 
}
extension Grammar.BracketedExpression 
{
    init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
    {
        try input.parse(as: Start.self)
        self.init(production: try input.parse(as: Expression.self))
        try input.parse(as: End.self)
    }
}
extension Grammar 
{
    typealias BracketedExpression = _GrammarBracketedExpression
}


protocol _GrammarPower 
{
    associatedtype Element
    associatedtype Result where Result:RangeReplaceableCollection 
    
    static 
    var exponent:Int 
    {
        get 
    }
    
    init(production:Result)
}
extension Grammar 
{
    struct EndOfStream<Terminal>:Error, Grammar.Parsable 
    {
        init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
        {
            if let terminal:Terminal = input.next() 
            {
                throw Grammar.Expected<Self, Terminal>.init(encountered: terminal)
            }
        }
        var production:Void 
        {
            ()
        }
    }
    
    typealias Power = _GrammarPower
    
    struct Reduce16<Element, Result>:Power where Result:RangeReplaceableCollection
    {
        static 
        var exponent:Int 
        {
            16
        }
        var production:Result
    }
    struct Reduce8<Element, Result>:Power where Result:RangeReplaceableCollection
    {
        static 
        var exponent:Int 
        {
            8
        }
        var production:Result
    }
    struct Reduce6<Element, Result>:Power where Result:RangeReplaceableCollection
    {
        static 
        var exponent:Int 
        {
            6
        }
        var production:Result
    }
    struct Reduce5<Element, Result>:Power where Result:RangeReplaceableCollection
    {
        static 
        var exponent:Int 
        {
            5
        }
        var production:Result
    }
    struct Reduce4<Element, Result>:Power where Result:RangeReplaceableCollection
    {
        static 
        var exponent:Int 
        {
            4
        }
        var production:Result
    }
    struct Reduce3<Element, Result>:Power where Result:RangeReplaceableCollection
    {
        static 
        var exponent:Int 
        {
            3
        }
        var production:Result
    }
    struct Reduce2<Element, Result>:Power where Result:RangeReplaceableCollection
    {
        static 
        var exponent:Int 
        {
            2
        }
        var production:Result
    }
    struct Reduce<Element, Result> where Result:RangeReplaceableCollection
    {
        var production:Result
    }
    struct Collect<Element, Result> where Result:RangeReplaceableCollection
    {
        var production:Result
    }
}
extension Grammar.Power where Element:Grammar.Parsable, Element.Production == Result.Element 
{
    typealias Terminal = Element.Terminal 
    
    init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
    {
        var production:Result = .init()
        for _:Int in 0 ..< Self.exponent
        {
            production.append(try input.parse(as: Element.self))
        }
        self.init(production: production)
    }
}
extension Grammar.Reduce2:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
}
extension Grammar.Reduce3:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
}
extension Grammar.Reduce4:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
}
extension Grammar.Reduce5:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
}
extension Grammar.Reduce6:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
}
extension Grammar.Reduce8:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
}
extension Grammar.Reduce16:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
}
extension Grammar.Reduce:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
    typealias Terminal = Element.Terminal 
    
    init<C>(parsing input:inout Grammar.Input<C>) throws where C:Collection, C.Element == Terminal
    {
        self.production = .init()
        self.production.append(         try  input.parse(as: Element.self))
        while let next:Result.Element = try? input.parse(as: Element.self)
        {
            self.production.append(next)
        }
    }
}
extension Grammar.Collect:Grammar.Parsable where Element:Grammar.Parsable, Element.Production == Result.Element 
{
    typealias Terminal = Element.Terminal 
    
    init<C>(parsing input:inout Grammar.Input<C>) where C:Collection, C.Element == Terminal
    {
        self.production = .init()
        while let next:Result.Element = try? input.parse(as: Element.self)
        {
            self.production.append(next)
        }
    }
}
extension Grammar 
{
    struct BigEndian:RangeReplaceableCollection, RandomAccessCollection
    {
        private
        var digits:[UInt8] 
        
        var startIndex:Int 
        {
            self.digits.startIndex 
        }
        var endIndex:Int 
        {
            self.digits.endIndex
        }
        subscript(_ index:Int) -> Int 
        {
            Int.init(self.digits[index])
        }
        
        init() 
        {
            self.digits = []
        }
        
        mutating 
        func append(_ digit:Int)
        {
            self.digits.append(UInt8.init(digit))
        }
        mutating 
        func replaceSubrange<C>(_ range:Range<Int>, with new:C) where C:Collection, C.Element == Int
        {
            self.digits.replaceSubrange(range, with: new.map(UInt8.init(_:)))
        }
        
        func `as`<T>(_ type:T.Type, radix:T) throws -> T where T:FixedWidthInteger
        {
            guard var value:T = self.digits.first.map(T.init(_:))
            else 
            {
                return T.zero 
            }
            for digit:UInt8 in self.digits.dropFirst()
            {
                guard   case (let product, false) = value.multipliedReportingOverflow(by: radix), 
                        case (let next,    false) = product.addingReportingOverflow(T.init(digit))
                else 
                {
                    throw Grammar.IntegerOverflowError<T>.init()
                }
                value = next 
            }
            return value
        }
        
        func match<T>(exactly value:T, radix:T) -> Bool where T:FixedWidthInteger 
        {
            var digits:ReversedCollection<[UInt8]>.Iterator = self.digits.reversed().makeIterator()
            var value:T = value 
            repeat 
            {
                let next:(quotient:T, remainder:T)  = value.quotientAndRemainder(dividingBy: radix)
                let remainder:UInt8                 = .init(next.remainder)
                value                               =       next.quotient 
                
                guard   let digit:UInt8 =  digits.next(), 
                            digit       == remainder 
                else 
                {
                    return false 
                }
            }
            while value     != 0 
            guard case .none = digits.next()
            else 
            {
                return false 
            }
            return true 
        }
    }
}
extension Grammar.BigEndian:CustomStringConvertible 
{
    var description:String 
    {
        var string:String = ""
        for digit:UInt8 in self.digits
        {
            // dont use the code from `Character.HexDigit.Anycase`, because 
            // radices may be greater than 16
            let character:Character
            if digit < 10 
            {
                character = .init(Unicode.Scalar.init(0x30 + digit))
            }
            else 
            {
                // lowercase 
                character = .init(Unicode.Scalar.init(0x57 + digit))
            }
            string.append(character)
        }
        return string 
    }
}
