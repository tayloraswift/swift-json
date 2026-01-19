extension ArraySlice: JSONEncodable where Element: JSONEncodable {
    @inlinable public func encode(to json: inout JSON) {
        {
            for element: Element in self {
                $0[+] = element
            }
        } (&json[as: JSON.ArrayEncoder.self])
    }
}
