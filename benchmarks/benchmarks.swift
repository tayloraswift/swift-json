#if os(macOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

#if os(macOS) || os(Linux)
import JSON_OLD
import enum JSON.JSON
import enum JSON.Grammar
import struct JSON.ParsingInput
import class Foundation.JSONDecoder
import struct Foundation.Data

@main 
enum Main 
{
    static 
    func main() throws
    {
        guard let data:[UInt8] = File.load(from: "cases/captured.json")
        else 
        {
            return 
        }
        
        let boundaries:[Range<Int>] = Self.boundaries(of: data)
        
        guard case (38295, 38295, 38295) = 
        (
            try Self.benchmark_ss_json(data),
            try Self.benchmark_ss_json_old(data),
            try Self.benchmarkFoundation(data, boundaries: boundaries)
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
    func benchmark_ss_json_old(_ json:[UInt8]) throws -> Int
    {
        try JSON_OLD.JSON._benchmark(parsing: json)
    }
    @inline(never)
    static 
    func benchmarkFoundation(_ json:[UInt8], boundaries:[Range<Int>]) throws -> Int
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

enum File 
{
    typealias Descriptor = UnsafeMutablePointer<FILE>
    
    private static 
    func count(descriptor:Descriptor) -> Int? 
    {
        let descriptor:Int32 = fileno(descriptor)
        guard descriptor != -1 
        else 
        {
            return nil 
        }
        
        guard let status:stat = 
        ({
            var status:stat = .init()
            guard fstat(descriptor, &status) == 0 
            else 
            {
                return nil 
            }
            return status 
        }())
        else 
        {
            return nil 
        }
        
        switch status.st_mode & S_IFMT 
        {
        case S_IFREG, S_IFLNK:
            break 
        default:
            return nil 
        }
        
        return Int.init(status.st_size)
    }
    
    static 
    func load(from path:String) -> [UInt8]?
    {
        guard   let descriptor:Descriptor   = fopen(path, "rb"), 
                let count:Int               = Self.count(descriptor: descriptor)
        else
        {
            return nil
        }
        
        defer 
        {
            fclose(descriptor)
        }
        
        let buffer:[UInt8] = .init(unsafeUninitializedCapacity: count)
        {
            $1 = fread($0.baseAddress, MemoryLayout<UInt8>.stride, count, descriptor)
        }
        guard buffer.count == count 
        else
        {
            return nil
        }
        return buffer
    }
    @discardableResult
    static 
    func save(_ buffer:[UInt8], to path:String) -> Void?
    {
        guard let descriptor:Descriptor   = fopen(path, "wb")
        else
        {
            print("failed to open file '\(path)'")
            return nil
        }
        defer 
        {
            fclose(descriptor)
        }
        let count:Int = buffer.withUnsafeBufferPointer
        {
            fwrite($0.baseAddress, MemoryLayout<UInt8>.stride, $0.count, descriptor)
        }
        guard count == buffer.count
        else
        {
            print("failed to write to file '\(path)'")
            return nil
        }
        return () 
    }
    @discardableResult
    static 
    func save(_ string:String, to path:String) -> Void?
    {
        Self.save([UInt8].init(string.utf8), to: path)
    }
    // creates directories 
    static 
    func pave(_ directories:[String]) 
    {
        // scan directory paths 
        for path:String in ((1 ... directories.count).map{ directories.prefix($0).joined(separator: "/") })
        {
            mkdir("\(path)/", 0o0755)
        }
    }
}
#endif
