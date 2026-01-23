extension LazyDropWhileSequence: JSONEncodable where Element: JSONEncodable {
    @inlinable public func encode(to json: inout JSON) { self.encodeElements(to: &json) }
}
