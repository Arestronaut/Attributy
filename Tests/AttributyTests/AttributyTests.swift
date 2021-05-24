import XCTest
@testable import Attributy

final class AttributyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Attributy().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
