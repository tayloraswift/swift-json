import Grammar
import JSON

let invalid:String = """
{"success":true,value:0.1}
"""
do
{
    let _:JSON.Node = try .init(parsing: invalid)
}
catch is Pattern.UnexpectedValueError
{
    print("JSON failed to parse!")
}
