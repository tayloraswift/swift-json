extension JSON 
{
    @inlinable public 
    func lint<T>(_ body:(inout LintingDictionary) throws -> T) throws -> T
    {
        try self.lint([], body)
    }
    @inlinable public 
    func lint<S, T>(_ ignored:S, _ body:(inout LintingDictionary) throws -> T) throws -> T
        where S:Sequence, S.Element == String
    {
        var dictionary:LintingDictionary 
        do 
        {
            // this `do` block is not for error catching, it is for ending 
            // the lifetime of `items` before passing a copy of it to `body`
            var items:[String: Self] = try self.as([String: Self].self) { $1 }
            for key:String in ignored 
            {
                items.removeValue(forKey: key)
            }
            dictionary = .init(items)
        }
        let value:T = try body(&dictionary)
        guard dictionary.items.isEmpty 
        else 
        {
            throw LintingError.init(unused: dictionary.items)
        }
        return value
    }
    
    @frozen public 
    struct LintingDictionary
    {
        public 
        var items:[String: JSON]
        
        @inlinable public 
        init(_ items:[String: JSON])
        {
            self.items = items
        }
        
        @inlinable public mutating 
        func remove<T>(_ key:String, _ body:(JSON) throws -> T) throws -> T
        {
            guard let value:JSON = self.items.removeValue(forKey: key)
            else 
            {
                throw PrimitiveError.undefined(key: key, in: self.items)
            }
            do 
            {
                #if swift(>=5.5)
                return try body(_move(value))
                #else 
                return try body(      value )
                #endif 
            }
            catch let error 
            {
                throw RecursiveError.dictionary(underlying: error, in: key)
            }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, _ body:(JSON) throws -> T) throws -> T?
        {
            guard let value:JSON = self.items.removeValue(forKey: key)
            else 
            {
                return nil
            }
            do 
            {
                return try body(_move(value))
            }
            catch let error 
            {
                throw RecursiveError.dictionary(underlying: error, in: key)
            }
        }
        
        // arrays 
        @inlinable public mutating 
        func remove<T>(_ key:String, as _:[JSON].Type = [JSON].self, _ body:([JSON]) throws -> T) throws -> T
        {
            try self.remove(key)
            {
                let array:[JSON] = try $0.as([JSON].self)
                do 
                {
                    return try body(array)
                }
                catch let error 
                {
                    throw RecursiveError.array(underlying: error)
                }
            }
        }
        @inlinable public mutating 
        func remove<T>(_ key:String, as _:[JSON]?.Type = [JSON]?.self, _ body:([JSON]) throws -> T) throws -> T?
        {
            try self.remove(key)
            {
                guard let array:[JSON] = try $0.as([JSON]?.self)
                else 
                {
                    return nil
                }
                do 
                {
                    return try body(array)
                }
                catch let error 
                {
                    throw RecursiveError.array(underlying: error)
                }
            }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, as _:[JSON].Type, _ body:([JSON]) throws -> T) throws -> T?
        {
            try self.pop(key)
            {
                let array:[JSON] = try $0.as([JSON].self)
                do 
                {
                    return try body(array)
                }
                catch let error 
                {
                    throw RecursiveError.array(underlying: error)
                }
            }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, as _:[JSON]?.Type, _ body:([JSON]) throws -> T) throws -> T?
        {
            try self.pop(key)
            {
                guard let array:[JSON] = try $0.as([JSON]?.self)
                else 
                {
                    return nil
                }
                do 
                {
                    return try body(array)
                }
                catch let error 
                {
                    throw RecursiveError.array(underlying: error)
                }
            } ?? nil
        }
        
        // null
        @inlinable public mutating 
        func remove(_ key:String, as type:Void.Type) throws 
        {
            try self.remove(key) { try $0.as(Void.self) }
        }
        @inlinable public mutating 
        func pop(_ key:String, as type:Void.Type) throws -> Void?
        {
            try self.pop(key) { try $0.as(Void.self) }
        }
        // booleans
        @inlinable public mutating 
        func remove(_ key:String, as type:Bool.Type = Bool.self) throws -> Bool
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func remove(_ key:String, as type:Bool?.Type = Bool?.self) throws -> Bool?
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop(_ key:String, as type:Bool.Type) throws -> Bool?
        {
            try self.pop(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop(_ key:String, as type:Bool?.Type) throws -> Bool?
        {
            try self.pop(key) { try $0.as(type) } ?? nil
        }
        // signed integers 
        @inlinable public mutating 
        func remove<T>(_ key:String, as type:T.Type = T.self) throws -> T
            where T:FixedWidthInteger & SignedInteger
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func remove<T>(_ key:String, as type:T?.Type = T?.self) throws -> T?
            where T:FixedWidthInteger & SignedInteger
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, as type:T.Type) throws -> T?
            where T:FixedWidthInteger & SignedInteger
        {
            try self.pop(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, as type:T?.Type) throws -> T?
            where T:FixedWidthInteger & SignedInteger
        {
            try self.pop(key) { try $0.as(type) } ?? nil
        }
        // unsigned integers 
        @inlinable public mutating 
        func remove<T>(_ key:String, as type:T.Type = T.self) throws -> T
            where T:FixedWidthInteger & UnsignedInteger
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func remove<T>(_ key:String, as type:T?.Type = T?.self) throws -> T?
            where T:FixedWidthInteger & UnsignedInteger
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, as type:T.Type) throws -> T?
            where T:FixedWidthInteger & UnsignedInteger
        {
            try self.pop(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, as type:T?.Type) throws -> T?
            where T:FixedWidthInteger & UnsignedInteger
        {
            try self.pop(key) { try $0.as(type) } ?? nil
        }
        // floating point 
        @inlinable public mutating 
        func remove<T>(_ key:String, as type:T.Type = T.self) throws -> T
            where T:BinaryFloatingPoint
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func remove<T>(_ key:String, as type:T?.Type = T?.self) throws -> T?
            where T:BinaryFloatingPoint
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, as type:T.Type) throws -> T?
            where T:BinaryFloatingPoint
        {
            try self.pop(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop<T>(_ key:String, as type:T?.Type) throws -> T?
            where T:BinaryFloatingPoint
        {
            try self.pop(key) { try $0.as(type) } ?? nil
        }
        // strings
        @inlinable public mutating 
        func remove(_ key:String, as type:String.Type = String.self) throws -> String
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func remove(_ key:String, as type:String?.Type = String?.self) throws -> String?
        {
            try self.remove(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop(_ key:String, as type:String.Type) throws -> String?
        {
            try self.pop(key) { try $0.as(type) }
        }
        @inlinable public mutating 
        func pop(_ key:String, as type:String?.Type) throws -> String?
        {
            try self.pop(key) { try $0.as(type) } ?? nil
        }
    }
} 
