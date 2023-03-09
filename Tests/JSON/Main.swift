import JSON
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        TestIntegerOverflow(tests / "integer-overflow")
    }
}
