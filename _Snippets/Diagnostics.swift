import Grammar
import JSON

let invalid:String = 
"""
{"success":true,value:0.1}
"""
do 
{
    let _:JSON = try JSON.Rule<String.Index>.Root.parse(diagnosing: invalid.utf8)
}
catch let error as ParsingError<String.Index> 
{
    let debug:String = error.annotate(source: invalid, 
        line: String.init(_:), newline: \.isNewline)
    print(debug)
}
