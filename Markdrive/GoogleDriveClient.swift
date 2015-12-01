import Foundation

class GoogleDriveClient {
  
  private let kKeychainItemName = "Markdrive API"
  private let kClientID = "41088727215-i68simor9c7ianupie1f0f8hnev2a6nk.apps.googleusercontent.com"
  private let kClientSecret = "l1sIRaNJ88g8kJtyC-jzArKF"
  
  var errorHandler: (error: NSError) -> Void = {_ in }
  
  func service() -> GTLServiceDrive {
    let service: GTLServiceDrive = GTLServiceDrive()
    service.authorizer = GTMOAuth2WindowController.authForGoogleFromKeychainForName(
      kKeychainItemName,
      clientID: kClientID,
      clientSecret: kClientSecret
    )
    return service
  }
  
  func query(query: String, handler: (GTLDriveFileList) -> Void) {
    let list = GTLQueryDrive.queryForFilesList() as! GTLQueryDrive
    list.q = query
    service().executeQuery(list, completionHandler: { (ticket, result, error) -> Void in
      if let error = error {
        self.errorHandler(error: error)
      } else {
        if let files = result as? GTLDriveFileList {
          handler(files)
        }
      }
    })
  }
}