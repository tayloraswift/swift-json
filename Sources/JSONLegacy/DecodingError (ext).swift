extension DecodingError
{
    init<T>(annotating error:any Error, initializing _:T.Type, path:[any CodingKey]) 
    {
        let description:String =
        """
        initializer for type '\(String.init(reflecting: T.self))' \
        threw an error while validating bson value at coding path \(path)
        """
        let context:DecodingError.Context = .init(codingPath: path, 
            debugDescription: description, underlyingError: error)
        self = .dataCorrupted(context)
    }
}
