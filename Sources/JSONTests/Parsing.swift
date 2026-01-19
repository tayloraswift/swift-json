import JSON
import Testing

@Suite enum Parsing {
    @Test static func Null() throws {
        guard case JSON.Node.null? = try .init(parsingFragment: "null") else {
            Issue.record()
            return
        }
    }

    @Test static func BoolTrue() throws {
        guard case JSON.Node.bool(true)? = try .init(parsingFragment: "true") else {
            Issue.record()
            return
        }
    }
    @Test static func BoolFalse() throws {
        guard case JSON.Node.bool(false)? = try .init(parsingFragment: "false") else {
            Issue.record()
            return
        }
    }

    @Test static func String() throws {
        guard case JSON.Node.string(.init("a"))? = try .init(parsingFragment: "\"a\"") else {
            Issue.record()
            return
        }
    }
}
