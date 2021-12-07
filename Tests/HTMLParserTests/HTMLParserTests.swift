import XCTest
@testable import HTMLParser

final class HTMLParserTests: XCTestCase {
	func testReminders() {
		XCTFail("strong")
		XCTFail("em")
		XCTFail("<p>mismatched case in tags - see crs SNT</P>")
	}
	
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HTMLParser().text, "Hello, World!")
    }
}
