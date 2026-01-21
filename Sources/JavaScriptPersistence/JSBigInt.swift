public final class JSBigInt {
    @usableFromInline let int128: Int128

    @inlinable init(int128: Int128) {
        self.int128 = int128
    }
}
extension JSBigInt: Equatable {
    @inlinable public static func == (a: JSBigInt, b: JSBigInt) -> Bool {
        a.int128 == b.int128
    }
}
