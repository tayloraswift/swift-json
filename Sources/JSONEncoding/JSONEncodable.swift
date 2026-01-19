import JSONAST

public protocol JSONEncodable {
    func encode(to json: inout JSON)
}
extension JSONEncodable where Self: StringProtocol {
    /// Encodes the UTF-8 bytes of this instance as a JSON string.
    @inlinable public func encode(to json: inout JSON) {
        json += JSON.Literal<Self>.init(self)
    }
}
extension JSONEncodable where Self: BinaryInteger {
    @inlinable public func encode(to json: inout JSON) {
        json += JSON.Literal<Self>.init(self)
    }
}
extension JSONEncodable where Self: BinaryFloatingPoint & LosslessStringConvertible {
    @inlinable public func encode(to json: inout JSON) {
        json += JSON.Literal<Self>.init(self)
    }
}
extension JSONEncodable where Self: RawRepresentable, RawValue: JSONEncodable {
    @inlinable public func encode(to json: inout JSON) {
        self.rawValue.encode(to: &json)
    }
}
