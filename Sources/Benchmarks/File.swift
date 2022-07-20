#if os(macOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif

enum File 
{
    struct ReadingError:Error, CustomStringConvertible 
    {
        enum Action 
        {
            case open 
            case query 
            case read(bytes:Int, read:Int)  
        }
        let path:String 
        let action:Action 
        
        var description:String 
        {
            switch self.action 
            {
            case .open: 
                return "could not open file '\(self.path)' for reading"
            case .query: 
                return "could not query information about file '\(self.path)'"
            case .read(bytes: let expected, read: let bytes): 
                return "could only read \(bytes) byte(s) from file '\(self.path)' (total \(expected))"
            }
        }
    }
    struct WritingError:Error, CustomStringConvertible 
    {
        enum Action 
        {
            case open 
            case write(bytes:Int, wrote:Int) 
        }
        let path:String
        let action:Action 
        
        var description:String 
        {
            switch self.action 
            {
            case .open: 
                return "could not open file '\(self.path)' writing"
            case .write(bytes: let expected, wrote: let bytes): 
                return "could only write \(bytes) byte(s) to file '\(self.path)' (total \(expected))"
            }
        }
    }
    #if os(macOS) || os(Linux)
    typealias Descriptor = UnsafeMutablePointer<FILE>
    
    private static 
    func count(descriptor:Descriptor) -> Int? 
    {
        let descriptor:Int32                = fileno(descriptor)
        guard descriptor                   != -1 
        else 
        {
            fatalError("unreachable")
        }
        var status:stat                     = .init()
        guard fstat(descriptor, &status)   ==  0 
        else 
        {
            return nil 
        }
        switch status.st_mode & S_IFMT 
        {
        case S_IFREG, S_IFLNK:
            return Int.init(status.st_size)
        default:
            return nil 
        }
    }
    
    static 
    func read(_:[UInt8].Type = [UInt8].self, from path:String) throws -> [UInt8]
    {
        try Self.read(from: path)
        {
            (descriptor:Descriptor, count:Int) in 
            let buffer:[UInt8]  = .init(unsafeUninitializedCapacity: count)
            {
                $1 = fread($0.baseAddress, 1, count, descriptor)
            }
            guard buffer.count == count 
            else
            {
                throw ReadingError.init(path: path, action: .read(bytes: count, read: buffer.count))
            }
            return buffer
        }
    }
    static 
    func read(_:String.Type = String.self, from path:String) throws -> String
    {
        try Self.read(from: path)
        {
            (descriptor:Descriptor, count:Int) in 
            let string:String = try .init(unsafeUninitializedCapacity: count)
            {
                let initialized:Int = fread($0.baseAddress, 1, count, descriptor)
                guard initialized == count
                else
                {
                    throw ReadingError.init(path: path, action: .read(bytes: count, read: initialized))
                }
                return initialized
            }
            return string
        }
    }
    static 
    func read<T>(from path:String, _ initializer:(Descriptor, Int) throws -> T) throws -> T
    {
        guard let descriptor:Descriptor = fopen(path, "rb")
        else 
        {
            throw ReadingError.init(path: path, action: .open)
        }
        defer 
        {
            fclose(descriptor)
        }
        guard let count:Int = Self.count(descriptor: descriptor)
        else 
        {
            throw ReadingError.init(path: path, action: .query)
        }
        return try initializer(descriptor, count)
    }
    static 
    func write(_ buffer:[UInt8], to path:String) throws
    {
        guard let descriptor:Descriptor = fopen(path, "wb")
        else
        {
            throw WritingError.init(path: path, action: .open)
        }
        defer 
        {
            fclose(descriptor)
        }
        let count:Int = buffer.withUnsafeBufferPointer
        {
            fwrite($0.baseAddress, 1, $0.count, descriptor)
        }
        guard count == buffer.count
        else
        {
            throw WritingError.init(path: path, action: .write(bytes: buffer.count, wrote: count))
        }
    }
    static 
    func make(directories:[String]) 
    {
        // scan directory paths 
        var path:String = ""
        for next:String in directories where !next.isEmpty
        {
            path += "\(next)/"
            mkdir(path, 0o0755)
        }
    }
    #endif
}
