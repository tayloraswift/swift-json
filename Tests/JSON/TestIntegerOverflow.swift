import JSON
import Testing

func TestIntegerOverflow(_ tests:TestGroup?)
{
    guard let tests:TestGroup
    else
    {
        return
    }
    
    let number:JSON.Number = .init(256)
    let json:JSON = .number(number)

    if  let tests:TestGroup = (tests / "int")
    {
        tests.do
        {
            tests.expect(try 256 ==? json.as(Int.self))
        }
    }
    if  let tests:TestGroup = (tests / "int64")
    {
        tests.do
        {
            tests.expect(try 256 ==? json.as(Int64.self))
        }
    }
    if  let tests:TestGroup = (tests / "int32")
    {
        tests.do
        {
            tests.expect(try 256 ==? json.as(Int32.self))
        }
    }
    if  let tests:TestGroup = (tests / "int16")
    {
        tests.do
        {
            tests.expect(try 256 ==? json.as(Int16.self))
        }
    }
    if  let tests:TestGroup = tests / "int8"
    {
        tests.do(catching: JSON.IntegerOverflowError.init(number: number, 
            overflows: Int8.self))
        {
            let _:Int8? = try json.as(Int8.self)
        }
    }

    if  let tests:TestGroup = (tests / "int64-max")
    {
        let json:JSON = .number(.init(Int64.max))
        tests.do
        {
            tests.expect(try Int64.max ==? json.as(Int64.self))
        }
    }
    if  let tests:TestGroup = (tests / "int64-min")
    {
        let json:JSON = .number(.init(Int64.min))
        tests.do
        {
            tests.expect(try Int64.min ==? json.as(Int64.self))
        }
    }

    if  let tests:TestGroup = (tests / "uint")
    {
        tests.do
        {
            tests.expect(try 256 ==? json.as(UInt.self))
        }
    }
    if  let tests:TestGroup = (tests / "uint64")
    {
        tests.do
        {
            tests.expect(try 256 ==? json.as(UInt64.self))
        }
    }
    if  let tests:TestGroup = (tests / "uint32")
    {
        tests.do
        {
            tests.expect(try 256 ==? json.as(UInt32.self))
        }
    }
    if  let tests:TestGroup = (tests / "uint16")
    {
        tests.do
        {
            tests.expect(try 256 ==? json.as(UInt16.self))
        }
    }
    if  let tests:TestGroup = tests / "uint8"
    {
        tests.do(catching: JSON.IntegerOverflowError.init(number: number, 
            overflows: UInt8.self))
        {
            let _:UInt8? = try json.as(UInt8.self)
        }
    }

    if  let tests:TestGroup = (tests / "uint64-max")
    {
        let json:JSON = .number(.init(UInt64.max))
        tests.do
        {
            tests.expect(try UInt64.max ==? json.as(UInt64.self))
        }
    }
}
