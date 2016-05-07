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
    
    static let sharedInstance = UserController()
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
                completion(success: false)
            }
        })
    }
    
    func fetchUser(completion: (success: Bool, user: User?) -> Void) {
        defaultContainer!.fetchUserRecordIDWithCompletionHandler { (userID, error) in
            if error == nil {
                let privateDatabase = self.defaultContainer!.privateCloudDatabase
                privateDatabase.fetchRecordWithID(userID!, completionHandler: { (user: CKRecord?, error) in
                    if error == nil {
                        let user = User(userID: userID!)
                        completion(success: true, user: user)
                    } else {
                        completion(success: false, user: nil)
                        print("Couldn't fetch record with ID")
                    }
                })
            } else {
                completion(success: false, user: nil)
                print("Couldn't fetch user record ID")
            }
        }
    }
    
    func fetchUserInfo(user: User, completion:(success: Bool, user: User?) -> Void) {
        defaultContainer!.discoverUserInfoWithUserRecordID(user.userID) { (info, error) in
            if error == nil {
                user.firstName = info?.displayContact?.givenName
                user.lastName = info?.displayContact?.familyName
                completion(success: true, user: user)
            } else {
                print("Couldn't fetch User info")
                completion(success: false, user: nil)
            }
        }
    }
    
    
    
}
