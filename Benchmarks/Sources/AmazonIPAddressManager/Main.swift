import ArgumentParser
import Foundation
import Grammar
import JSON
import JSONDecoding
import SystemExtras

struct Log:Decodable 
{
    let timestamp:String
    let level:String
    let thread:String
    let logger:String
    let message:String
    
    enum CodingKeys:String, CodingKey 
    {
        case timestamp = "@timestamp"
        case level
        case thread = "thread_name"
        case logger = "logger_name"
        case message
    }
}
extension Log:JSONDecodable
{
    init(json:JSON) throws 
    {
        let json:JSON.Dictionary = try .init(json: json)
        self.timestamp  = try json[CodingKeys.timestamp.rawValue].decode(to: String.self)
        self.level      = try json[CodingKeys.level.rawValue].decode(to: String.self)
        self.thread     = try json[CodingKeys.thread.rawValue].decode(to: String.self)
        self.logger     = try json[CodingKeys.logger.rawValue].decode(to: String.self)
        self.message    = try json[CodingKeys.message.rawValue].decode(to: String.self)
    }
}

@main 
struct Main:ParsableCommand
{
    @Argument(help: "path to test data file (aws ip address manager log, jsonl format)")
    var path:String 

    func run() throws
    {
        let data:String = try FilePath.init(self.path).read()
        let clock:SuspendingClock = .init()

        let swiftJSONWithLinter:Duration = try clock.measure 
        {
            let logs:[Log] = try Self.benchmarkSwiftJSONWithLinter(data)
            print("swift-json: decoded \(logs.count) logs")
        }
        let swiftJSON:Duration = try clock.measure 
        {
            let logs:[Log] = try Self.benchmarkSwiftJSON(data)
            print("swift-json: decoded \(logs.count) logs")
        }
        let foundation:Duration = try clock.measure 
        {
            let logs:[Log] = try Self.benchmarkFoundation(data)
            print("foundation: decoded \(logs.count) logs")
        }
        print("swift-json decoding time (fast decoding api): \(swiftJSONWithLinter)")
        print("swift-json decoding time (compatibility api): \(swiftJSON)")
        print("foundation decoding time:                     \(foundation)")
    }
    
    @inline(never)
    static 
    func benchmarkSwiftJSONWithLinter(_ string:String) throws -> [Log]
    {
        var logs:[Log] = []
        var input:ParsingInput<NoDiagnostics<String.UTF8View>> = .init(string.utf8)
        while let log:[(key:String, value:JSON)] = 
            input.parse(as: JSON.Rule<String.Index>.Object?.self)
        {
            logs.append(try .init(json: .object(log)))
        }
        return logs
    }
    @inline(never)
    static 
    func benchmarkSwiftJSON(_ string:String) throws -> [Log]
    {
        var logs:[Log] = []
        var input:ParsingInput<NoDiagnostics<String.UTF8View>> = .init(string.utf8)
        while let log:[(key:String, value:JSON)] = 
            input.parse(as: JSON.Rule<String.Index>.Object?.self)
        {
            logs.append(try .init(from: JSON.object(log) as any Decoder))
        }
        return logs
    }
    @inline(never)
    static 
    func benchmarkFoundation(_ string:String) throws -> [Log]
    {
        let decoder:JSONDecoder = .init()
        return try string.split(whereSeparator: \.isNewline).map 
        { 
            try decoder.decode(Log.self, from: $0.data(using: .utf8) ?? .init()) 
        }
    }
}
