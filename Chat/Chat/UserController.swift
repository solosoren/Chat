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
    var myRelationshipRecord:CKRecord?
    var myRelationship:Relationship?
    
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
                let newUser = User.init(userID: userID!, fullName: nil, friends: nil, userPic: nil)
                self.defaultContainer!.privateCloudDatabase.fetchRecordWithID(userID!, completionHandler: { (user: CKRecord?, error) in
                    if error == nil {
                    completion(success: true, user: newUser)
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
    
    
//    TODO: FIX UP
    func setFriends(user:User, record:CKRecord, completion:(success:Bool, user:User?) -> Void) {
        self.defaultContainer?.discoverAllContactUserInfosWithCompletionHandler({ (info, error) in
            if error == nil {
                var references = [CKReference]()
                for i in info! {
                    let recordID = i.userRecordID
                    let reference = CKReference(recordID: recordID!, action: CKReferenceAction.DeleteSelf)
                    references.append(reference)
                }
                user.friends = references
                record.setObject(references, forKey: "Friends")
                
                self.defaultContainer?.privateCloudDatabase.saveRecord(record, completionHandler: { (record, error) in
                    if error == nil {
                        completion(success: true, user: user)
                    } else {
                        NSLog("Couldn't get friends: \(error?.localizedDescription)")
                        completion(success: false, user: nil)
                    }
                })
            } else {
                user.friends! = []
            }
        })
    }
    
    func acceptRequest(user:User, friend:Relationship, completion:(success: Bool, record:CKRecord?) -> Void) {
        self.queryForRelationshipByName(friend.fullName) { (success, relationshipRecord) in
            if success {
                if relationshipRecord!["Friends"] != nil {
                    var priorFriends = relationshipRecord!["Friends"] as! [CKReference]
                    let ref = CKReference(recordID: user.userID, action: .DeleteSelf)
                    priorFriends.append(ref)
                    relationshipRecord?.setObject(priorFriends, forKey: "Friends")
                    
                    self.defaultContainer?.publicCloudDatabase.saveRecord(relationshipRecord!, completionHandler: { (record, error) in
                        if error == nil {
                            completion(success: true, record: record)
                        } else {
                            completion(success: false, record: nil)
                        }
                    })
                } else {
                    let ref = CKReference(recordID: user.userID, action: .DeleteSelf)
                    let requests = [ref]
                    relationshipRecord?.setObject(requests, forKey: "Friends")
                    
                    self.defaultContainer?.publicCloudDatabase.saveRecord(relationshipRecord!, completionHandler: { (record, error) in
                        if error == nil {
                            completion(success: true, record: record)
                        } else {
                            completion(success: false, record: nil)
                            NSLog("ERROR: \(error)")
                        }
                    })
                }
                
            } else {
                completion(success: false, record: nil)
            }
        }
    }
    
    
//    TODO: query to see if the friend is already a user
    
    func sendRequest(user:User, friend:Relationship, completion:(success: Bool, record:CKRecord?) -> Void) {
        self.queryForRelationshipByName(friend.fullName) { (success, relationshipRecord) in
            if success {
//                TODO: This might not work. Haven't tested out whether I need this or not
                if relationshipRecord!["FriendRequests"] != nil {
                    var priorRequests = relationshipRecord!["FriendRequests"] as! [CKReference]
                    let ref = CKReference(recordID: user.userID, action: .DeleteSelf)
                    priorRequests.append(ref)
                    relationshipRecord?.setObject(priorRequests, forKey: "FriendRequests")
                    
                    self.defaultContainer?.publicCloudDatabase.saveRecord(relationshipRecord!, completionHandler: { (record, error) in
                        if error == nil {
                            completion(success: true, record: record)
                        } else {
                            completion(success: false, record: nil)
                        }
                    })
                } else {
                    let ref = CKReference(recordID: user.userID, action: .DeleteSelf)
                    let requests = [ref]
                    relationshipRecord?.setObject(requests, forKey: "FriendRequests")
                    
                    self.defaultContainer?.publicCloudDatabase.saveRecord(relationshipRecord!, completionHandler: { (record, error) in
                        if error == nil {
                            completion(success: true, record: record)
                        } else {
                            completion(success: false, record: nil)
//                            NSLog("ERROR: \(error)")
                        }
                    })
                }
            } else {
                completion(success: false, record: nil)
            }
        }
    }
    
    func saveRecordArray(array:[CKReference], record: CKRecord, string: String, completion:(success:Bool) -> Void) {
        record.setObject(array, forKey: string)
        self.defaultContainer?.publicCloudDatabase.saveRecord(record, completionHandler: { (record, error) in
            if error == nil {
                completion(success: true)
            } else {
                completion(success: false)
            }
        })
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
                            lastName = info?.displayContact?.familyName {
                            let fullName = "\(firstName) \(lastName)"
                            user.fullName = fullName
                            completion(success: true, user: user)
                        }
                    } else {
                        NSLog("COULDN'T FETCH USER INFO")
                        completion(success: false, user: nil)
                    }
                }
            } else {
                NSLog("COULDN'T FETCH USER")
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
    
    func fetchRecordWithID(recordID: CKRecordID, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        publicDatabase.fetchRecordWithID(recordID) { (record, error) in
            
            if let completion = completion {
                completion(record: record, error: error)
            }
        }
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
    
    func createRelationship(user: User, completion:(success: Bool, ref: CKReference?) -> Void) {
        let ref = CKReference(recordID: user.userID, action: .DeleteSelf)
        let relationship = Relationship.init(fullName: user.fullName!, userID: ref, requests: nil, friends: nil, profilePic: nil)
        let record = CKRecord(recordType: "Relationship")
        
        record.setValuesForKeysWithDictionary(relationship.toAnyObject() as! [String: AnyObject])
        self.defaultContainer!.publicCloudDatabase.saveRecord(record) { (relationship, error) in
            if error == nil {
                completion(success: true, ref: ref)
            } else {
                NSLog("ERROR: \(error?.localizedDescription)")
                completion(success: false, ref: nil)
            }
        }
    }
    
    func queryForMyRelationship(user: User, completion:(success: Bool, relationshipRecord: CKRecord?) -> Void) {
        let pred = NSPredicate(format: "FullName == %@",  user.fullName!)
        let query = CKQuery(recordType: "Relationship", predicate: pred)
        self.defaultContainer?.publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if let records = records {
                if records.count != 0 {
                    for relationship in records {
                        if relationship == records.last {
                            completion(success: true, relationshipRecord: relationship)
                        }
                    }
                } else {
                    completion(success: false, relationshipRecord: nil)
                }

            } else {
                NSLog("ERROR Querying for my relationship: \(error?.localizedDescription)")
                completion(success: false, relationshipRecord: nil)
            }
        })
    }
    
    func queryForRelationshipByName(userName:String, completion:(success:Bool, relationshipRecord: CKRecord?) -> Void) {
        let pred = NSPredicate(format: "FullName == %@", userName)
        let query = CKQuery(recordType: "Relationship", predicate: pred)
        self.defaultContainer?.publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error == nil {
                for relationship in records! {
                    if relationship == records?.last {
                        completion(success: true, relationshipRecord: relationship)
                    } else {
                        completion(success: false, relationshipRecord: nil)
                    }
                }
                
            } else {
                completion(success: false, relationshipRecord: nil)
            }
        })
    }
    
    func queryForRelationshipbyUID(userID: CKRecordID, completion:(success: Bool, relationshipRecord:CKRecord?) -> Void) {
        let pred = NSPredicate(format: "UserIDRef = %@", userID)
        let query = CKQuery(recordType: "Relationship", predicate: pred)
        self.defaultContainer?.publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
            if error == nil {
                for relationship in records! {
                    if relationship == records?.last {
                        completion(success: true, relationshipRecord: relationship)
                    }
                }
            } else {
                NSLog("Querying for relationship by UID ERROR: \(error?.localizedDescription)")
                completion(success: false, relationshipRecord: nil)
            }
        })
    }

    
    
    func searchAllUsers(searchTerm: String, completion:(success: Bool, users: [Relationship]?) -> Void) {
        var tempUsers = [Relationship]()
        let predicate = NSPredicate(format: "FullName BEGINSWITH %@", searchTerm)
        let query = CKQuery(recordType: "Relationship", predicate: predicate)
        dispatch_async(dispatch_get_main_queue()) {
            self.defaultContainer?.publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records, error) in
                if let records = records {
                    for record in records {
                        if record["UserIDRef"] != nil && record["FullName"] != nil && record["ImageKey"] != nil {
                                let uid = record["UserIDRef"] as! CKReference
                                let fullName = record["FullName"] as! String
                                let pic = record["ImageKey"] as! CKAsset
                                let relationship = Relationship(fullName: fullName, userID: uid, requests: nil, friends: nil, profilePic: pic)
                                tempUsers.append(relationship)
                        }
                        if record == records.last {
                            completion(success: true, users: tempUsers)
                        }
                        
//                        self.defaultContainer?.publicCloudDatabase.fetchRecordWithID(ID, completionHandler: { (userRecord, error) in
//                            if error == nil {
//                                let UID = userRecord?.recordID
//                                let fullName = record["FullName"] as! String
//                                let pic = record["ImageKey"] as! CKAsset
//                                let user = User(userID:UID!, fullName:fullName, friends:nil, userPic:pic)
//                                tempUsers.append(user)
//                                if record == records.last {
//                                    completion(success: true, users: tempUsers)
//                                }
//                            } else {
//                                if record == records.last {
//                                    completion(success: false, users: nil)
//                                }
//                                print("error searching users \(error?.localizedDescription)")
//                            }
//                        })
                    }
                } else {
                    completion(success: false, users: nil)
                    print("error searching users \(error?.localizedDescription)")
                }
            })
        }
    }
    
    
    func grabImage(string: String, completion:(success: Bool, image: UIImage?) -> Void) {
        self.queryForRelationshipByName(string) { (success, relationshipRecord) in
            if success {
                if let asset = relationshipRecord!["ImageKey"] as? CKAsset {
                    let image = asset.image
                    completion(success: true, image: image)
                } else {
                    completion(success: false, image: nil)
                }
            } else {
                completion(success: false, image: nil)
            }
        }
    }
    
    func grabImageByUID(recordID: CKRecordID, completion:(success: Bool, image:UIImage?) -> Void) {
        queryForRelationshipbyUID(recordID) { (success, relationshipRecord) in
            if success {
                if let asset = relationshipRecord!["ImageKey"] as? CKAsset {
                    let image = asset.image
                    completion(success: true, image: image)
                } else {
                    completion(success: true, image: nil)
                }
            } else {
                completion(success: false, image: nil)
            }
            
        }
    }
    
//    pass in friend when you request so they subscribe to the request
    func subscribeToFriendRequests(relationship:Relationship, completion:((success:Bool, error: NSError?) -> Void)?) {
        let recordID = relationship.userID
        let predicate = NSPredicate(format: "recordID == %@", recordID)
        ConversationController.sharedInstance.subscribe("Relationship", predicate: predicate, subscriptionID: ("\(relationship.userID)A"), contentAvailable: true, alertBody: "You have a new friend request", desiredKeys: ["FriendRequests"], options: .FiresOnRecordUpdate) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(success:success, error:error)
            }
        }
    }
    
    func removeFriend(friend:Relationship, currentRel: Relationship, completion:(success: Bool) -> Void) {
        queryForRelationshipByName(friend.fullName) { (success, relationshipRecord) in
            if success {
                if relationshipRecord!["Friends"] != nil {
                    var friends = relationshipRecord!["Friends"] as! [CKReference]
                    let index = 0
                    for friend in friends {
                        index + 1
                        if friend == currentRel.userID {
                            friends.removeAtIndex(index)
                        }
                    }
                    self.saveRecordArray(friends, record: relationshipRecord!, string: "Friends", completion: { (success) in
                        if success {
                            completion(success: true)
                        } else {
                            completion(success: false)
                        }
                    })
                }
            }
        }
        
    }
    
}










