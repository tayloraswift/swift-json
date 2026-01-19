extension JSON {
    /// An integer overflow occurred while converting a number literal to a desired type.
    ///
    /// This error is thrown by decoders, and is different from
    /// `Grammar.Pattern.IntegerOverflowError`, which is thrown by the parser.
    public protocol NumericOverflowError<Representation>: Error, CustomStringConvertible {
        associatedtype Representation
        /// The number literal that could not be converted.
        var number: Number { get }
    }
}
extension JSON.NumericOverflowError {
    public var description: String {
        "numeric literal '\(self.number)' overflows decoded type '\(Representation.self)'"
    }
}
