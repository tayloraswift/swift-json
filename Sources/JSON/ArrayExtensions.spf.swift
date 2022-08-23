extension Array where Element == JSON 
{
    /// Executes the given closure on the array element at the given index for further decoding.
    /// Records the index of the element being decoded if the closure throws an error, and 
    /// propogates it up the call chain.
    /// 
    /// -   Parameters:
    ///     -   index: An index into this array. This index must be within the array’s bounds.
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
    ///     -   index: An index into this array. This index must be within the array’s bounds.
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
    ///     -   index: An index into this array. This index must be within the array’s bounds.
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

    // null
    @inlinable public 
    func load(_ index:Int, as _:Void.Type) throws 
    {
        try self.load(index) { try $0.as(Void.self) }
    }
}

extension Array where Element == JSON 
{
    @inlinable public 
    func load<T>(_ index:Int, as _:Bool.Type, 
        _ body:(Bool) throws -> T) throws -> T
    {
        try self.load(index) { try body(try $0.as(Bool.self)) }
    }
    @inlinable public 
    func load<T>(_ index:Int, as _:Bool?.Type, 
        _ body:(Bool) throws -> T) throws -> T?
    {
        try self.load(index) { try $0.as(Bool?.self).map(body) } ?? nil
    }
}

extension Array where Element == JSON 
{
    @inlinable public 
    func load<T>(_ index:Int, as _:String.Type, 
        _ body:(String) throws -> T) throws -> T
    {
        try self.load(index) { try body(try $0.as(String.self)) }
    }
    @inlinable public 
    func load<T>(_ index:Int, as _:String?.Type, 
        _ body:(String) throws -> T) throws -> T?
    {
        try self.load(index) { try $0.as(String?.self).map(body) } ?? nil
    }
}

extension Array where Element == JSON 
{
    @inlinable public 
    func load(_ index:Int, as _:Bool.Type = Bool.self) 
        throws -> Bool
    {
        try self.load(index) { try $0.as(Bool.self) }
    }
    @inlinable public 
    func load(_ index:Int, as _:Bool?.Type = Bool?.self) 
        throws -> Bool?
    {
        try self.load(index) { try $0.as(Bool?.self) }
    }
}

extension Array where Element == JSON 
{
    @inlinable public 
    func load(_ index:Int, as _:String.Type = String.self) 
        throws -> String
    {
        try self.load(index) { try $0.as(String.self) }
    }
    @inlinable public 
    func load(_ index:Int, as _:String?.Type = String?.self) 
        throws -> String?
    {
        try self.load(index) { try $0.as(String?.self) }
    }
}

extension Array where Element == JSON 
{
    @inlinable public 
    func load(_ index:Int, as _:[JSON].Type = [JSON].self) 
        throws -> [JSON]
    {
        try self.load(index) { try $0.as([JSON].self) }
    }
    @inlinable public 
    func load(_ index:Int, as _:[JSON]?.Type = [JSON]?.self) 
        throws -> [JSON]?
    {
        try self.load(index) { try $0.as([JSON]?.self) }
    }
}

extension Array where Element == JSON 
{
    @inlinable public 
    func load<Integer, T>(_ index:Int, as _:Integer.Type, 
        _ body:(Integer) throws -> T) throws -> T
        where Integer:FixedWidthInteger & SignedInteger
    {
        try self.load(index) { try body(try $0.as(Integer.self)) }
    }
    @inlinable public 
    func load<Integer, T>(_ index:Int, as _:Integer?.Type, 
        _ body:(Integer) throws -> T) throws -> T?
        where Integer:FixedWidthInteger & SignedInteger
    {
        try self.load(index) { try $0.as(Integer?.self).map(body) }
    }

    @inlinable public 
    func load<Integer>(_ index:Int, as _:Integer.Type = Integer.self) 
        throws -> Integer
        where Integer:FixedWidthInteger & SignedInteger
    {
        try self.load(index) { try $0.as(Integer.self) }
    }
    @inlinable public 
    func load<Integer>(_ index:Int, as _:Integer?.Type = Integer?.self) 
        throws -> Integer?
        where Integer:FixedWidthInteger & SignedInteger
    {
        try self.load(index) { try $0.as(Integer?.self) }
    }
}

extension Array where Element == JSON 
{
    @inlinable public 
    func load<Integer, T>(_ index:Int, as _:Integer.Type, 
        _ body:(Integer) throws -> T) throws -> T
        where Integer:FixedWidthInteger & UnsignedInteger
    {
        try self.load(index) { try body(try $0.as(Integer.self)) }
    }
    @inlinable public 
    func load<Integer, T>(_ index:Int, as _:Integer?.Type, 
        _ body:(Integer) throws -> T) throws -> T?
        where Integer:FixedWidthInteger & UnsignedInteger
    {
        try self.load(index) { try $0.as(Integer?.self).map(body) }
    }

    @inlinable public 
    func load<Integer>(_ index:Int, as _:Integer.Type = Integer.self) 
        throws -> Integer
        where Integer:FixedWidthInteger & UnsignedInteger
    {
        try self.load(index) { try $0.as(Integer.self) }
    }
    @inlinable public 
    func load<Integer>(_ index:Int, as _:Integer?.Type = Integer?.self) 
        throws -> Integer?
        where Integer:FixedWidthInteger & UnsignedInteger
    {
        try self.load(index) { try $0.as(Integer?.self) }
    }
}

extension Array where Element == JSON 
{
    @inlinable public 
    func load<Binary, T>(_ index:Int, as _:Binary.Type, 
        _ body:(Binary) throws -> T) throws -> T
        where Binary:BinaryFloatingPoint
    {
        try self.load(index) { try body(try $0.as(Binary.self)) }
    }
    @inlinable public 
    func load<Binary, T>(_ index:Int, as _:Binary?.Type, 
        _ body:(Binary) throws -> T) throws -> T?
        where Binary:BinaryFloatingPoint
    {
        try self.load(index) { try $0.as(Binary?.self).map(body) }
    }

    @inlinable public 
    func load<Binary>(_ index:Int, as _:Binary.Type = Binary.self) 
        throws -> Binary
        where Binary:BinaryFloatingPoint
    {
        try self.load(index) { try $0.as(Binary.self) }
    }
    @inlinable public 
    func load<Binary>(_ index:Int, as _:Binary?.Type = Binary?.self) 
        throws -> Binary?
        where Binary:BinaryFloatingPoint
    {
        try self.load(index) { try $0.as(Binary?.self) }
    }
}