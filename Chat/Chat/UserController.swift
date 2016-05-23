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
    var currentUser:User?
    
    init() {
        defaultContainer = CKContainer.defaultContainer()
    }
    
    func requestPermission(completion:(success: Bool) -> Void) {
        defaultContainer!.requestApplicationPermission(CKApplicationPermissions.UserDiscoverability, completionHandler: { applicationPermissionStatus, error in
            if applicationPermissionStatus == CKApplicationPermissionStatus.Granted {
                CKAccountStatus.Available
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
                        let newUser = User.init(userID: userID!)
                        
                        self.defaultContainer?.discoverAllContactUserInfosWithCompletionHandler({ (info, error) in
                            if error == nil {
                                var references = [CKReference]()
                                for i in info! {
                                    let recordID = i.userRecordID
                                    let reference = CKReference(recordID: recordID!, action: CKReferenceAction.DeleteSelf)
                                    
                                    references.append(reference)
                                }
                                user!.setValue(references, forKey: "Friends")

                                self.defaultContainer?.privateCloudDatabase.saveRecord(user!, completionHandler: { (user, error) in
                                    completion(success: true, user: newUser)
                                })
                                
                            } else {
                                newUser.friends! = []
                                completion(success: true, user: newUser)
                            }
                        })
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
    
    func checkForUser(completion:(success: Bool) -> Void) {
        self.defaultContainer?.statusForApplicationPermission(.UserDiscoverability, completionHandler: { (permissionStatus, error) in
            if permissionStatus == CKApplicationPermissionStatus.Granted {
                self.fetchUser({ (success, user) in
                    if success {
                        self.fetchUserInfo(user!, completion: { (success, user) in
                            if success {
                                self.currentUser = user
                                completion(success: true)
                            } else {
                                print("error fecthing user info")
                                completion(success: false)
                            }
                        })
                    } else {
                        print("error fetching user")
                        completion(success: false)
                    }
                })
            } else {
                completion(success: false)
            }
        })
        
    }
    
    func fetchRecord(completion:(success: Bool, record: CKRecord?) -> Void) {
        self.defaultContainer?.fetchUserRecordIDWithCompletionHandler({ (userID, error) in
            if error == nil {
                self.defaultContainer?.privateCloudDatabase.fetchRecordWithID(userID!, completionHandler: { (record, error) in
                    if error == nil {
                        completion(success: true, record: record)
                    } else {
                        completion(success: false, record: nil)
                    }
                })
            }
        })
    }
    
        
}
