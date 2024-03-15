import XCTest
import Testing

final class AllTests:XCTestCase
{
    func testAll() async
    {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
