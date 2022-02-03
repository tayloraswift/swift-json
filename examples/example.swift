import JSON 

@main 
enum Main 
{
    struct Decimal:Codable  
    {
        let units:Int 
        let places:Int 
    }
    struct Response:Codable 
    {
        let success:Bool 
        let value:Decimal
    }
    static 
    func main() throws
    {
        let string:String = 
        """
        {"success":true,"value":0.1}
        """
        let decoder:JSON        = 
            try Grammar.parse(string.utf8, as: JSON.Rule<String.Index>.Root.self)
        let response:Response  = 
            try .init(from: decoder)
        
        print(response)
        
        let invalid:String = 
        """
        {"success":true,value:0.1}
        """
        do 
        {
            let _:JSON = 
                try Grammar.parse(diagnosing: invalid.utf8, as: JSON.Rule<String.Index>.Root.self)
        }
        catch let error as ParsingError<String.Index> 
        {
            print(error.annotate(source: invalid, line: String.init(_:), newline: \.isNewline))
        }
    }
}
