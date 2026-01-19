extension JSON {
    /// An integer overflow occurred while converting a number literal to a desired type.
    ///
    /// This error is thrown by decoders, and is different from
    /// `Grammar.Pattern.IntegerOverflowError`, which is thrown by the parser.
    public struct IntegerOverflowError<Representation>: Error, Equatable, Sendable {
        /// The number literal that could not be converted.
        public let number: Number

        public init(number: Number) {
            self.number = number
        }
    }
}
