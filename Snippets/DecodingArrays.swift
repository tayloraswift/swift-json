import JSON
import JSONDecoding

// snippet.point-definition
struct Point
{
    let x:Double
    let y:Double
}
// snippet.point-decoder
extension Point:JSONDecodable
{
    init(json:JSON) throws
    {
        let array:JSON.Array = try .init(json: json)
        try array.shape.expect(count: 2)
        self.init(
            x: try array[0].decode(to: Double.self),
            y: try array[1].decode(to: Double.self))
    }
}
// snippet.main
func decode(message:String) throws -> [(Point, Point, Point)]
{
    // snippet.parse
    let json:JSON.Array = try .init(parsing: message)
    // snippet.check-shape
    try json.shape.expect(multipleOf: 3)
    // snippet.decode
    return try stride(from: json.startIndex, to: json.endIndex, by: 3).map
    {
        (
            try json[$0    ].decode(to: Point.self),
            try json[$0 + 1].decode(to: Point.self),
            try json[$0 + 2].decode(to: Point.self)
        )
    }
    // snippet.hide
}
print(try decode(message: 
"""
[
    [0, 0],
    [0, 1],
    [1, 0]
]
"""))
