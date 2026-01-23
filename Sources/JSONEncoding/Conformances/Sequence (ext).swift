extension Sequence where Self: JSONEncodable, Element: JSONEncodable {
    // this does not directly witness the requirement, we don’t want it to show up on
    // ``String``, for instance
    @inlinable func encodeElements(to json: inout JSON) {
        {
            for element: Element in self {
                $0[+] = element
            }
        } (&json[as: JSON.ArrayEncoder.self])
    }
}
