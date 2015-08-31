import Cocoa

class MasterViewController: NSViewController {
  
  private let kKeychainItemName = "Markdrive API"
  private let kClientID = "41088727215-i68simor9c7ianupie1f0f8hnev2a6nk.apps.googleusercontent.com"
  private let kClientSecret = "l1sIRaNJ88g8kJtyC-jzArKF"
  
  let service: GTLServiceDrive = GTLServiceDrive()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    service.authorizer = GTMOAuth2WindowController.authForGoogleFromKeychainForName(
      kKeychainItemName,
      clientID: kClientID,
      clientSecret: kClientSecret
    )
  }
  
  override func viewDidAppear() {
    if let authorizer = service.authorizer, canAuthorize = authorizer.canAuthorize where canAuthorize {
      println("AUTHORIZED")
      self.fetchFiles()
    } else {
      println("UNAUTHORIZED")
      GTMOAuth2WindowController(scope: kGTLAuthScopeDriveReadonly, clientID: kClientID, clientSecret: kClientSecret, keychainItemName: kKeychainItemName, resourceBundle: nil)
        .signInSheetModalForWindow(nil, completionHandler: { (authentication, error) -> Void in
          println("RESULT \(authentication)")
          self.service.authorizer = authentication
          self.fetchFiles()
        })
    }
  }
  
  func fetchFiles() {
    let query = GTLQueryDrive.queryForFilesList() as! GTLQueryDrive
    query.q = "mimeType = '"
    service.executeQuery(query, completionHandler: { (ticket, result, error) -> Void in
      if let error = error {
        println(error.localizedDescription)
      } else {
        let files = result as? GTLDriveFileList
        if let items = files!.items() where !items.isEmpty {
          for file in items as! [GTLDriveFile] {
            println("\(file.title) (\(file.identifier))")
          }
        } else {
          println("No files found.")
        }
      }
    })
  }
  
}
