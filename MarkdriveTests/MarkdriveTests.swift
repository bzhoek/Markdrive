import Cocoa
import XCTest

class MarkdriveTests: XCTestCase {

    private let kKeychainItemName = "Drive API"
    private let kClientID = "41088727215-i68simor9c7ianupie1f0f8hnev2a6nk.apps.googleusercontent.com"
    private let kClientSecret = "l1sIRaNJ88g8kJtyC-jzArKF"
    
    func testApiKey() {
        let readyExpectation = expectationWithDescription("ready")
        
        let service: GTLServiceDrive = GTLServiceDrive()
        service.APIKey = "AIzaSyDkqpkC7mHUnH97Vc5d65yPYItbgHZ3jEk"
        let query = GTLQueryDrive.queryForFilesList() as! GTLQueryDrive
        service.executeQuery(query, completionHandler: { (ticket, result, error) -> Void in
            if let error = error {
                println(error.localizedDescription)
                return
            }
            
            let files = result as? GTLDriveFileList
//            if let items = files!.items() where !items.isEmpty {
//                for file in items as! [GTLDriveFile] {
//                    println("\(file.title) (\(file.identifier))")
//                }
//            } else {
//                println("No files found.")
//            }
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5.0, handler:nil)
    }
    
    func testOAuth() {
        let readyExpectation = expectationWithDescription("ready")
        GTMOAuth2WindowController.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: kClientSecret
        )
        
        
        let service: GTLServiceDrive = GTLServiceDrive()
        let query = GTLQueryDrive.queryForFilesList() as! GTLQueryDrive
        service.executeQuery(query, completionHandler: { (ticket, result, error) -> Void in
            if let error = error {
                println(error.localizedDescription)
                return
            }
            
            let files = result as? GTLDriveFileList
            //            if let items = files!.items() where !items.isEmpty {
            //                for file in items as! [GTLDriveFile] {
            //                    println("\(file.title) (\(file.identifier))")
            //                }
            //            } else {
            //                println("No files found.")
            //            }
            readyExpectation.fulfill()
        })
        

        
        waitForExpectationsWithTimeout(5.0, handler:nil)

    }
    
}
