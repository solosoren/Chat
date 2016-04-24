//
//  UserController.swift
//  Chat
//
//  Created by Soren Nelson on 4/22/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

class UserController {
    
    var defaultContainer: CKContainer?
    var currentUser: User?
    
    init() {
        defaultContainer = CKContainer.defaultContainer()
    }
    
    func requestPermission(completion:(success: Bool) -> Void) {
        defaultContainer!.requestApplicationPermission(CKApplicationPermissions.UserDiscoverability, completionHandler: { applicationPermissionStatus, error in
            if applicationPermissionStatus == CKApplicationPermissionStatus.Granted {
                completion(success: true)
            } else {
//                error handling
                completion(success: false)
            }
        })
    }
    
    func getUser(completion: (success: Bool, user: User?) -> Void) {
        defaultContainer!.fetchUserRecordIDWithCompletionHandler { (userID, error) in
            if error == nil {
                let privateDatabase = self.defaultContainer!.privateCloudDatabase
                privateDatabase.fetchRecordWithID(userID!, completionHandler: { (user: CKRecord?, error) in
                    if error == nil {
                        let user = User(userID: userID!)
                        completion(success: true, user: user)
                    } else {
                        completion(success: false, user: nil)
//                        error handling
                    }
                })
            } else {
                completion(success: false, user: nil)
//                error handling
            }
        }
    }
    
    func getUserInfo(user: User, completion:(success: Bool, user: User?) -> Void) {
        defaultContainer!.discoverUserInfoWithUserRecordID(user.userID) { (info, error) in
            if error == nil {
                user.pFirstName = info?.displayContact?.givenName
                user.pLastName = info?.displayContact?.familyName
//                let publicDatabase = self.defaultContainer!.publicCloudDatabase
                completion(success: true, user: user)
            } else {
//                error handling?
                completion(success: false, user: nil)
            }
        }
    }
    

//    move to log in View or move alert to view
    
    func iCloudLogin(completion:(success: Bool) -> Void) {
        self.requestPermission { (success) in
            if success {
                self.getUser({ (success, user) in
                    if success {
                        self.currentUser = user!
                        self.getUserInfo(user!, completion: { (success, user) in
                            if success {
                                completion(success: true)
                            }
                        })
                    } else {
//                        error handling
                        print("Didn't Work")
                    }
                })
            } else {
                let iCloudAlert = UIAlertController(title: "iCloud Error", message: "Error connecting to iCloud. Go to Settings to change iCloud settings", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                iCloudAlert.addAction(ok)
//                presentViewController(icloudAlert)
            }
        }
    }
    
    
    
}
