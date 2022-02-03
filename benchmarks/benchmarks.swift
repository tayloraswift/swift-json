#if os(macOS) || os(Linux)
import struct Foundation.Data
import class Foundation.JSONDecoder
import JSON

@main 
enum Main 
{
    static 
    func main() throws
    {
        let data:[UInt8]            = try File.read(from: "cases/captured.json")
        let boundaries:[Range<Int>] = Self.boundaries(of: data)
        
        guard case (38295, 38295) = 
        (
            try Self.benchmark_ss_json(data),
            try Self.benchmark_foundation(data, boundaries: boundaries)
        )
        else 
        {
            fatalError("wrong number of json messages decoded")
        }
    }
    
    @inline(never)
    static 
    func boundaries(of json:[UInt8]) -> [Range<Int>]
    {
        var input:ParsingInput<Grammar.NoDiagnostics<[UInt8]>> = .init(json)
        var indices:[Range<Int>]    = []
        var start:Int               = input.index 
        while let _:JSON = input.parse(as: JSON.Rule<Int>.Root?.self)
        {
            indices.append(start ..< input.index)
            start = input.index
        }
        return indices
    }
    
    @inline(never)
    static 
    func benchmark_ss_json(_ json:[UInt8]) throws -> Int
    {
        try JSON._benchmark(parsing: json)
    }
    @inline(never)
    static 
    func benchmark_foundation(_ json:[UInt8], boundaries:[Range<Int>]) throws -> Int
    {
        let decoder:JSONDecoder = .init()
        var count:Int           = 0
        for range:Range<Int> in boundaries 
        {
            let data:Data   = .init(json[range])
            let _:JSON      = try decoder.decode(JSON.self, from: data)
            count          += 1
        }
        return count
    }
}

#endif
