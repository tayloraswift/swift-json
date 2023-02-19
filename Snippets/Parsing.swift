import Grammar
import JSON

let string:String = 
"""
{"success": true, "value": 0.1}
"""

let json:JSON = try JSON.Rule<String.Index>.Root.parse(diagnosing: string.utf8)
print(json)
