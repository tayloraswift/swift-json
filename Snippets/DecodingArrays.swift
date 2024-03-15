import JSON

// snippet.POINT
struct Point
{
    let x:Double
    let y:Double
}
// snippet.POINT_DECODE
extension Point:JSONDecodable
{
    init(json:JSON.Node) throws
    {
        let array:JSON.Array = try .init(json: json)
        try array.shape.expect(count: 2)
        self.init(x: try array[0].decode(), y: try array[1].decode())
    }
}
// snippet.MAIN
func decode(message:String) throws -> [(Point, Point, Point)]
{
    // snippet.MAIN_PARSE
    let json:JSON.Array = try .init(parsing: message)
    // snippet.MAIN_CHECK_SHAPE
    try json.shape.expect(multipleOf: 3)
    // snippet.MAIN_DECODE
    return try stride(from: json.startIndex, to: json.endIndex, by: 3).map
    {
        (
            try json[$0    ].decode(to: Point.self),
            try json[$0 + 1].decode(to: Point.self),
            try json[$0 + 2].decode(to: Point.self)
        )
    }
    // snippet.end
}
// snippet.MAIN_CALL
print(try decode(message: "[[0, 0], [0, 1], [1, 0]]"))
