import ArgumentParser
import Foundation
import Grammar
import JSON
import SystemExtras

@main 
struct Main:ParsableCommand
{
    @Argument(help: "path to test data file")
    var path:String 

    func run() throws
    {
        let data:[UInt8] = try FilePath.init(self.path).read()

        // the irony here is that ``Foundation/JSONDecoder`` cannot break message boundaries, 
        // so we need to use `/swift-json`’s parser. 
        var input:ParsingInput<NoDiagnostics<[UInt8]>> = .init(data)
        var boundaries:[Range<Int>] = []
        var start:Int = input.index 
        while let _:JSON = input.parse(as: JSON.Rule<Int>.Root?.self)
        {
            boundaries.append(start ..< input.index)
            start = input.index
        }

        let clock:SuspendingClock = .init()

        let us:Duration = try clock.measure 
        {
            let parsed:Int = try Self.benchmarkSwiftJSON(data)
            print("swift-json: decoded \(parsed) messages")
        }
        let them:Duration = try clock.measure 
        {
            let parsed:Int = try Self.benchmarkFoundation(data, boundaries: boundaries)
            print("foundation: decoded \(parsed) messages")
        }
        print("swift-json decoding time: \(us)")
        print("foundation decoding time: \(them)")
    }
    
    @inline(never)
    static 
    func benchmarkSwiftJSON(_ json:[UInt8]) throws -> Int
    {
        try JSON.Rule<Int>.Root.parse(json, into: [JSON].self).count
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
