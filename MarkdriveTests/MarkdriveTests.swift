import Cocoa
import XCTest

class MarkdriveTests: XCTestCase {
  
  var client: GoogleDriveClient!
  
  override func setUp() {
    client = GoogleDriveClient()
    client.errorHandler = {
      XCTFail($0.localizedDescription)
    }
  }
  
  func testListFolder() {
    let expectation = expectationWithDescription("list")
    client.query("mimeType = 'text/markdown'") {
      XCTAssertFalse($1.isEmpty)
      expectation.fulfill()
      for file in $1 {
        print("\(file.title) (\(file.identifier))")
      }
    }
    waitForExpectationsWithTimeout(5.0, handler:nil)
  }
  
  func testCreateFileInFolder() {
    with(expectationWithDescription("create")) { expectation in
      var identifier: String?
      self.client.query("'root' in parents and title = 'markdrive' and mimeType = 'application/vnd.google-apps.folder'") {
        identifier = $1.first?.identifier
        self.client.createFile("hello.md", identifier: identifier) {_ in
          expectation.fulfill()
        }
      }
    }
    waitForExpectationsWithTimeout(5.0, handler:nil)
  }

  func testCreateFile() {
    with(expectationWithDescription("create")) { expectation in
      self.client.createFile("markdown.md", identifier: "0B64Ufmc6SF1_S09tWEtDejZHSlE") {_ in
        expectation.fulfill()
      }
    }
    waitForExpectationsWithTimeout(5.0, handler:nil)
  }

  func testUpdateFile() {
    with(expectationWithDescription("create")) { expectation in
      self.client.updateFile("markdown.md", parent: "0B64Ufmc6SF1_S09tWEtDejZHSlE", content: "Goodbye, world") {_ in
        expectation.fulfill()
      }
    }
    waitForExpectationsWithTimeout(5.0, handler:nil)
  }

}
