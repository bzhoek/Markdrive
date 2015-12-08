import Foundation

func with<T>(a: T, closure:(T)->()) -> T {
  closure(a)
  return a
}

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

  
  func query(query: GTLQueryProtocol, handler: (AnyObject?) -> Void) {
    service().executeQuery(query, completionHandler: { (_, result, error) -> Void in
      if let error = error {
        self.errorHandler(error: error)
      } else {
        handler(result)
      }
    })
  }
  
  func file(query: AnyObject, handler: (GTLDriveFile?) -> Void) {
    self.query(query as! GTLQueryDrive) { handler($0 as? GTLDriveFile) }
  }
  
  func list(query: GTLQueryProtocol, handler: (GTLDriveFileList?) -> Void) {
    self.query(query) { handler($0 as? GTLDriveFileList) }
  }

  func list(query: GTLQueryProtocol, handler: (GTLDriveFileList, [GTLDriveFile]) -> Void) {
    self.query(query) {
      if let list = $0 as? GTLDriveFileList  {
        if let items = list.items() as? [GTLDriveFile] {
          handler(list, items)
        }
      }
    }
  }
  
  func query(query: String, handler: (GTLDriveFileList, [GTLDriveFile]) -> Void) {
    self.list(with(GTLQueryDrive.queryForFilesList() as! GTLQueryDrive) {$0.q = query}, handler: handler)
  }
  
  func createFolder(name: String, handler: (GTLDriveFile?) -> Void) {
    self.file(GTLQueryDrive.queryForFilesInsertWithObject(with(GTLDriveFile()) {
      $0.title = name
      $0.mimeType = "application/vnd.google-apps.folder";
      }, uploadParameters: nil)  as! GTLQueryDrive, handler: handler)
  }
  
  func createFile(name: String, identifier: String?, handler: (GTLDriveFile?) -> Void) {
    let file = with(GTLDriveFile()) {
      $0.title = name
      $0.parents = [with(GTLDriveParentReference()) {
        $0.identifier = identifier
        }]
    }
    let content = "# Hello, world".dataUsingEncoding(NSUTF8StringEncoding)
    let params = GTLUploadParameters(data: content, MIMEType: "text/plain")
    self.file(GTLQueryDrive.queryForFilesInsertWithObject(file, uploadParameters: params), handler: handler)
  }
  
  func updateFile(name: String, parent: String, content: String, handler: (GTLDriveFile?) -> Void) {
    self.query("'\(parent)' in parents and title = '\(name)' and mimeType = 'text/plain' and trashed = false") { _, files in
      print(files)
      let file = with(GTLDriveFile()) {
        $0.title = name
      }
      let params = GTLUploadParameters(data: content.dataUsingEncoding(NSUTF8StringEncoding), MIMEType: "text/plain")
      self.file(GTLQueryDrive.queryForFilesUpdateWithObject(file, fileId: files.first?.identifier, uploadParameters: params), handler: handler)
    }
  }
}