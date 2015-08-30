//
//  MasterViewController.swift
//  Markdrive
//
//  Created by Bas van der Hoek on 29/08/15.
//  Copyright (c) 2015 Bas van der Hoek. All rights reserved.
//

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
        let viewController = GTMOAuth2WindowController(scope: kGTLAuthScopeDriveReadonly, clientID: kClientID, clientSecret: kClientSecret, keychainItemName: kKeychainItemName, resourceBundle: nil)
        if let authorizer = service.authorizer, canAuth = authorizer.canAuthorize where canAuth {
            println("AUTHORIZED")
        } else {
            println("UNAUTHORIZED")
            viewController.signInSheetModalForWindow(nil, completionHandler: { (authentication, error) -> Void in
                println("RESULT \(authentication)")
                self.service.authorizer = authentication
            })
        }
        
    }
    
}
