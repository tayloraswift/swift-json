import JSONAST

extension JSON.Literal<Never?> {
    /// Encodes `null` to the provided JSON stream.
    @inlinable static func += (json: inout JSON, self: Self) {
        json.utf8 += "null".utf8
    }
}
extension JSON.Literal<Bool> {
    /// Encodes `true` or `false` to the provided JSON stream.
    @inlinable static func += (json: inout JSON, self: Self) {
        json.utf8 += (self.value ? "true" : "false").utf8
    }
}
extension JSON.Literal where Value: BinaryInteger {
    /// Encodes this literal’s integer ``value`` to the provided JSON stream. The value’s
    /// ``CustomStringConvertible description`` witness must format the value in base-10.
    @inlinable static func += (json: inout JSON, self: Self) {
        json.utf8 += self.value.description.utf8
    }
}
extension JSON.Literal where Value: BinaryFloatingPoint & LosslessStringConvertible {
    /// Encodes this literal’s floating-point ``value`` to the provided JSON stream.
    @inlinable static func += (json: inout JSON, self: Self) {
        if  self.value.isSignalingNaN {
            json.utf8 += "snan".utf8
        } else if self.value.isNaN {
            json.utf8 += "nan".utf8
        } else if self.value.isInfinite {
            if case .minus = self.value.sign {
                json.utf8.append(0x2D) // "-"
            }

            json.utf8 += "inf".utf8
        } else {
            json.utf8 += self.value.description.utf8
        }
    }
}
