import Glibc

enum Demangle 
{
    private 
    typealias Function = @convention(c) 
    (
        _ name:UnsafePointer<UInt8>?,
        _ count:Int,
        _ output:UnsafeMutablePointer<UInt8>?,
        _ capacity:UnsafeMutablePointer<Int>?,
        _ flags:UInt32
    ) -> UnsafeMutablePointer<Int8>?
    
    private static 
    var function:Function = 
    {
        guard let swift:UnsafeMutableRawPointer = dlopen(nil, RTLD_NOW)
        else 
        {
            fatalError("could not load swift runtime")
        }
        guard let symbol:UnsafeMutableRawPointer = dlsym(swift, "swift_demangle") 
        else 
        {
            fatalError("could not load symbll 'swift_demangle'")
        }
        return unsafeBitCast(symbol, to: Function.self)
    }()
    
    static 
    subscript(mangled:String) -> String
    {
        guard let string:UnsafeMutablePointer<Int8> = self.function(mangled, mangled.utf8.count, nil, nil, 0)
        else 
        {
            print("warning: could not demangle symbol '\(mangled)'")
            return mangled 
        }
        defer 
        {
            string.deallocate()
        }
        return String.init(cString: string)
    }
}
