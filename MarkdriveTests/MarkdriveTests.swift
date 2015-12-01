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
    let readyExpectation = expectationWithDescription("ready")
    client.query("mimeType = 'text/plain'") {
      if let items = $0.items() where !items.isEmpty {
        readyExpectation.fulfill()
        for file in items as! [GTLDriveFile] {
          print("\(file.title) (\(file.identifier))")
        }
      } else {
        XCTFail("No files found.")
      }
    }
    waitForExpectationsWithTimeout(10.0, handler:nil)
  }
  
}
