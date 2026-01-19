@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: JSONDecodable {
    @inlinable public init(json: JSON.Node) throws {
        self = try json.cast { $0.as(Self.self) }
    }
}
