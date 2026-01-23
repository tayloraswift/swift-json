extension String {
    init(_ literal: JSON.Literal<String>) {
        var json: JSON = .init(utf8: [])

        json.utf8.reserveCapacity(literal.value.utf8.count + 2)
        json += literal

        self.init(decoding: json.utf8, as: Unicode.UTF8.self)
    }
}
