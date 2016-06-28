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
    
//    request permission to access icloud
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
    
//    fetch user initially and find contacts. Set contacts to friends. Creates User
    func fetchUser(completion: (success: Bool, user: User?) -> Void) {
        defaultContainer!.fetchUserRecordIDWithCompletionHandler { (userID, error) in
            if userID != nil {
                let privateDatabase = self.defaultContainer!.privateCloudDatabase
                privateDatabase.fetchRecordWithID(userID!, completionHandler: { (user: CKRecord?, error) in
                    if error == nil {
                        let newUser = User.init(userID: userID!, fullName: nil, friends: nil, userPic: nil)
            
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
                                    if error == nil {
//                                        completion(success: true, user: newUser)
                                    } else {
                                        print("Couldn't get friends: %@", error?.localizedDescription)
//                                        completion(success: false, user: nil)
                                    }
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
    
    
//      get name for user
    func fetchUserInfo(user: User, completion:(success: Bool, user: User?) -> Void) {
        self.fetchRecord { (success, record) in
            if success {
                self.defaultContainer!.discoverUserInfoWithUserRecordID(user.userID) { (info, error) in
                    if error == nil {
                        if let firstName = info?.displayContact?.givenName,
                        lastName = info?.displayContact!.familyName {
                            let fullName = "\(firstName) \(lastName)"
                            user.fullName = fullName
                            completion(success: true, user: user)
                        }
                    } else {
                        print("Couldn't fetch User info")
                        completion(success: false, user: nil)
                    }
                }
            }
        }
        
    }
    
//      does the same thing as ^^ but this sets name to icloud
    func fetchUserInfoAndSetUserName(user: User, completion:(success: Bool, user: User?) -> Void) {
        self.fetchRecord { (success, record) in
            if success {
                self.defaultContainer!.discoverUserInfoWithUserRecordID(user.userID) { (info, error) in
                    if error == nil {
                        
                        if let firstName = info?.displayContact?.givenName,
                            lastName = info?.displayContact!.familyName {
                            let fullName = "\(firstName) \(lastName)"
                            user.fullName = fullName
                            record?.setValue(fullName, forKey: "Name")
                            
                            if let record = record {
                                let ckArray = [record]
                                let savedRecordsOp = CKModifyRecordsOperation()
                                savedRecordsOp.recordsToSave = ckArray
                                savedRecordsOp.savePolicy = .ChangedKeys
                                savedRecordsOp.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                                    
                                    if error != nil {
                                        completion(success: false, user: nil)
                                    } else {
                                        completion(success: true, user: user)
                                    }
                                }
                                self.defaultContainer?.privateCloudDatabase.addOperation(savedRecordsOp)
                            }
                        }
//                        self.defaultContainer?.privateCloudDatabase.saveRecord(record!, completionHandler: { (record, error) in
//                            if error == nil {
//                                completion(success: true, user: user)
//                            } else {
//                                print("error")
//                                completion(success: false, user: nil)
//                            }
//                        
//                    })
                    } else {
                        print("Couldn't fetch User info")
                        completion(success: false, user: nil)
                    }
                }
            } else {
                completion(success: false, user: nil)
            }
        }
    }

//      startup app check to see if user has accepted permission
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
    
//    fetch record by user id
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
            } else {
                completion(success: false, record: nil)
            }
        })
    }
    
    func createRelationship(user: User, completion:(success: Bool) -> Void) {
        let ref = CKReference(recordID: user.userID, action: .DeleteSelf)
        let relationship = Relationship.init(fullName: user.fullName!, userID: ref)
        let record = CKRecord(recordType: "Relationship")
        
        record.setValuesForKeysWithDictionary(relationship.toAnyObject() as! [String: AnyObject])
        self.defaultContainer!.publicCloudDatabase.saveRecord(record) { (relationship, error) in
            if error == nil {
                completion(success: true)
            } else {
                print(error?.localizedDescription)
                completion(success: false)
            }
        }
        
    }

    func setImage(completion:(success:Bool, image: UIImage?) -> Void) {
        self.fetchRecord { (success, record) in
            if success {
                if let asset = record!["ImageKey"] as? CKAsset, image = asset.image {
                    completion(success: success, image: image)
                }
            } else {
                completion(success: false, image: nil)
            }
        }
    }
    
    
    func searchAllUsers(searchTerm: String, completion:(success: Bool, users: [User]?) -> Void) {
        var tempUsers = [User]()
        let predicate = NSPredicate(format: "FullName BEGINSWITH %@", searchTerm)
        let query = CKQuery(recordType: "Relationship", predicate: predicate)

        self.defaultContainer?.publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if let records = records {
                for record in records {
                    let ref = record["UserIDRef"] as! CKReference
                    let ID = ref.recordID
                    self.defaultContainer?.publicCloudDatabase.fetchRecordWithID(ID, completionHandler: { (userRecord, error) in
                        if error == nil {
                            let UID = userRecord?.recordID
                            let fullName = record["FullName"] as! String
                            let user = User(userID:UID!, fullName:fullName, friends:nil, userPic:nil)
                            tempUsers.append(user)
                            if record == records.last {
                                completion(success: true, users: tempUsers)
                            }
                        } else {
                            completion(success: false, users: nil)
                            print("error searching users \(error?.localizedDescription)")
                        }
                    })
                }
            } else {
                completion(success: false, users: nil)
                print("error searching users \(error?.localizedDescription)")
            }
        })
    }
    
}









