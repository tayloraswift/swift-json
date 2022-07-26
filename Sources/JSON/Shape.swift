extension JSON 
{
    @inlinable public 
    func shape<T>(_ count:Int, 
        decode body:([Self]) throws -> T) throws -> T
    {
        let aggregate:[Self] = try self.as([JSON].self)
        if  aggregate.count == count 
        {
            return try body(aggregate)
        }
        else 
        {
            throw PrimitiveError.shaping(aggregate: aggregate, count: count)
        }
    }
    @inlinable public 
    func shape<T>(where predicate:(_ count:Int) throws -> Bool, 
        decode body:([Self]) throws -> T) throws -> T
    {
        let aggregate:[Self] = try self.as([JSON].self)
        if try predicate(aggregate.count)
        {
            return try body(aggregate)
        }
        else 
        {
            throw PrimitiveError.shaping(aggregate: aggregate)
        }
    }
}

extension Array where Element == JSON 
{
    /// Executes the given closure on the array element at the given index for further decoding.
    /// Records the index of the element being decoded if the closure throws an error, and 
    /// propogates it up the call chain.
    /// 
    /// -   Parameters:
    ///     -   index: An index into this array. This index must be within the array’s bounds; 
    ///         to check array lengths, use the ``JSON.shape(_:_:)`` or 
    ///         ``JSON.shape(where:decode:)`` APIs.
    /// 
    /// -   Returns: The result of the closure, if it succeeds.
    /// 
    /// >   Throws:
    ///     A ``JSON//RecursiveError.array(underlying:at:)`` 
    ///     if an error was thrown from within the given closure.
    @inlinable public  
    func load<T>(_ index:Int, _ body:(JSON) throws -> T) throws -> T
    {
        do 
        {
            return try body(self[index])
        }
        catch let error 
        {
            throw JSON.RecursiveError.array(underlying: error, at: index)
        }
    }

    /// Attempts to unwrap the array element at the specified index as a variant array, and passes 
    /// the it to the given closure for further decoding. Records the index of the element being 
    /// decoded if the closure throws an error, and propogates it up the call chain.
    /// 
    /// -   Parameters:
    ///     -   index: An index into this array. This index must be within the array’s bounds; 
    ///         to check array lengths, use the ``JSON.shape(_:_:)`` or 
    ///         ``JSON.shape(where:decode:)`` APIs.
    /// 
    /// -   Returns: The result of the closure, if it succeeds.
    /// 
    /// Calling this method is equivalent to the following:
    /* 
    ```swift 
    try self.load(index)
    {
        try body(try $0.as([JSON].self))
    }
    ```
    */
    /// 
    /// >   Throws:
    ///     A ``JSON//RecursiveError.array(underlying:at:)`` if an error 
    ///     was thrown from within the given closure.
    @inlinable public  
    func load<T>(_ index:Int, as _:[JSON].Type = [JSON].self, _ body:([JSON]) throws -> T) throws -> T
    {
        try self.load(index) { try body(try $0.as([JSON].self)) }
    }
    /// Attempts to unwrap the array element at the specified index as either a variant array or an 
    /// explicit ``JSON/.null`` value, and passes the array to the given closure for further decoding 
    /// if it is not ``JSON/.null``. Records the index of the element being decoded if the closure 
    /// throws an error, and propogates it up the call chain.
    /// 
    /// -   Parameters:
    ///     -   index: An index into this array. This index must be within the array’s bounds; 
    ///         to check array lengths, use the ``JSON.shape(_:_:)`` or 
    ///         ``JSON.shape(where:decode:)`` APIs.
    /// 
    /// -   Returns: The result of the closure, if it succeeds, or [`nil`]() if the array element 
    ///     is an explicit ``JSON/.null``.
    /// 
    /// Calling this method is equivalent to the following:
    /* 
    ```swift 
    try self.load(index)
    {
        try $0.as([JSON]?.self).map(body)
    }
    ```
    */
    /// 
    /// >   Throws:
    ///     A ``JSON//RecursiveError.array(underlying:at:)`` if an error 
    ///     was thrown from within the given closure.
    @inlinable public  
    func load<T>(_ index:Int, as _:[JSON]?.Type = [JSON]?.self, _ body:([JSON]) throws -> T) throws -> T?
    {
        try self.load(index) { try $0.as([JSON]?.self).map(body) }
    }

    @inlinable public  
    func load(_ index:Int, as _:[JSON].Type = [JSON].self) throws -> [JSON]
    {
        try self.load(index, as: [JSON].self) { $0 }
    }
    @inlinable public  
    func load(_ index:Int, as _:[JSON]?.Type = [JSON]?.self) throws -> [JSON]?
    {
        try self.load(index, as: [JSON]?.self) { $0 }
    }

    // null
    @inlinable public 
    func load(_ index:Int, as type:Void.Type) throws 
    {
        try self.load(index) { try $0.as(Void.self) }
    }
    // booleans
    @inlinable public 
    func load(_ index:Int, as type:Bool.Type = Bool.self) throws -> Bool
    {
        try self.load(index) { try $0.as(type) }
    }
    @inlinable public 
    func load(_ index:Int, as type:Bool?.Type = Bool?.self) throws -> Bool?
    {
        try self.load(index) { try $0.as(type) }
    }
    // signed integers 
    @inlinable public 
    func load<T>(_ index:Int, as type:T.Type = T.self) throws -> T
        where T:FixedWidthInteger & SignedInteger
    {
        try self.load(index) { try $0.as(type) }
    }
    @inlinable public 
    func load<T>(_ index:Int, as type:T?.Type = T?.self) throws -> T?
        where T:FixedWidthInteger & SignedInteger
    {
        try self.load(index) { try $0.as(type) }
    }
    // unsigned integers 
    @inlinable public 
    func load<T>(_ index:Int, as type:T.Type = T.self) throws -> T
        where T:FixedWidthInteger & UnsignedInteger
    {
        try self.load(index) { try $0.as(type) }
    }
    @inlinable public 
    func load<T>(_ index:Int, as type:T?.Type = T?.self) throws -> T?
        where T:FixedWidthInteger & UnsignedInteger
    {
        try self.load(index) { try $0.as(type) }
    }
    // floating point 
    @inlinable public 
    func load<T>(_ index:Int, as type:T.Type = T.self) throws -> T
        where T:BinaryFloatingPoint
    {
        try self.load(index) { try $0.as(type) }
    }
    @inlinable public 
    func load<T>(_ index:Int, as type:T?.Type = T?.self) throws -> T?
        where T:BinaryFloatingPoint
    {
        try self.load(index) { try $0.as(type) }
    }
    // strings
    @inlinable public 
    func load(_ index:Int, as type:String.Type = String.self) throws -> String
    {
        try self.load(index) { try $0.as(type) }
    }
    @inlinable public 
    func load(_ index:Int, as type:String?.Type = String?.self) throws -> String?
    {
        try self.load(index) { try $0.as(type) }
    }
}