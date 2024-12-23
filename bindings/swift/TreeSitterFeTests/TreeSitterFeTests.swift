import XCTest
import SwiftTreeSitter
import TreeSitterFe

final class TreeSitterFeTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_fe())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Fe grammar")
    }
}
