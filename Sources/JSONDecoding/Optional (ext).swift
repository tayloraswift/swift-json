extension Optional: JSONDecodable where Wrapped: JSONDecodable {
    @inlinable public init(json: borrowing JSON.Node) throws {
        if  case .null = copy json {
            self = .none
        } else {
            self = .some(try .init(json: json))
        }
    }
}
