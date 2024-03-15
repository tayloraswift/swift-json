import JSON

let string:String = """
{"success": true, "value": 0.1}
"""

let json:JSON.Node = try .init(parsing: string)

print(json)
