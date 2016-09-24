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
    var alerts = [Conversation]()
    
    init() {
        defaultContainer = CKContainer.default()
    }
    
//    request permission to access icloud
    func requestPermission(_ completion:@escaping (_ success: Bool) -> Void) {
        defaultContainer!.requestApplicationPermission(CKApplicationPermissions.userDiscoverability, completionHandler: { applicationPermissionStatus, error in
            if applicationPermissionStatus == CKApplicationPermissionStatus.granted {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
//    fetch user initially and find contacts. Set contacts to friends. Creates User
    func fetchUser(_ completion: @escaping (_ success: Bool, _ user: User?) -> Void) {
        defaultContainer!.fetchUserRecordID { (userID, error) in
            if userID != nil {
                let newUser = User.init(userID: userID!, fullName: nil, friends: nil, userPic: nil)
                self.defaultContainer!.privateCloudDatabase.fetch(withRecordID: userID!, completionHandler: { (user: CKRecord?, error) in
                    if error == nil {
                        completion(true, newUser)
                    } else {
                        print(error)
                        print("Couldn't fetch record with ID")
                        completion(false, nil)
                    }
                })
            } else if error == nil {
                print("Something wrong with internet connection most likely")
            } else {
                print(error)
                print("Couldn't fetch user record ID")
                completion(false, nil)
            }
        }
    }
    
    
//    TODO: FIX UP
//    func setFriends(_ user:User, record:CKRecord, completion:@escaping (_ success:Bool, _ user:User?) -> Void) {
        
        
//        self.defaultContainer?.discoverAllContactUserInfos(completionHandler: { (info, error) in
//            if error == nil {
//                var references = [CKReference]()
//                for i in info! {
//                    let recordID = i.userRecordID
//                    let reference = CKReference(recordID: recordID!, action: CKReferenceAction.deleteSelf)
//                    references.append(reference)
//                }
//                user.friends = references
//                record.setObject(references as CKRecordValue?, forKey: "Friends")
//
//                self.defaultContainer?.privateCloudDatabase.save(record, completionHandler: { (record, error) in
//                    if error == nil {
//                        completion(true, user)
//                    } else {
//                        NSLog("Couldn't get friends: \(error?.localizedDescription)")
//                        completion(false, nil)
//                    }
//                })
//            } else {
//                user.friends! = []
//            }
//        })
//    }
    
//    MARK: Friend Requests
    func acceptRequest(_ user:User, friend:Relationship, completion:@escaping (_ success: Bool, _ record:CKRecord?) -> Void) {
        self.queryForRelationshipByName(friend.fullName) { (success, relationshipRecord) in
            if success {
                if relationshipRecord!["Friends"] != nil {
                    var priorFriends = relationshipRecord!["Friends"] as! [CKReference]
                    let ref = CKReference(recordID: user.userID, action: .deleteSelf)
                    priorFriends.append(ref)
                    relationshipRecord?.setObject(priorFriends as CKRecordValue?, forKey: "Friends")
                    
                    self.defaultContainer?.publicCloudDatabase.save(relationshipRecord!, completionHandler: { (record, error) in
                        if error == nil {
                            completion(true, record)
                        } else {
                            completion(false, nil)
                        }
                    })
                } else {
                    let ref = CKReference(recordID: user.userID, action: .deleteSelf)
                    let requests = [ref]
                    relationshipRecord?.setObject(requests as CKRecordValue?, forKey: "Friends")
                    
                    self.defaultContainer?.publicCloudDatabase.save(relationshipRecord!, completionHandler: { (record, error) in
                        if error == nil {
                            completion(true, record)
                        } else {
                            completion(false, nil)
                            NSLog("ERROR: \(error)")
                        }
                    })
                }
                
            } else {
                completion(false, nil)
            }
        }
    }
    
    
    func sendRequest(_ user:User, friend:Relationship, completion:@escaping (_ success: Bool, _ record:CKRecord?, _ alreadyFriend:Bool?, _ alreadyRequested:Bool ) -> Void) {
        self.queryForRelationshipByName(friend.fullName) { (success, relationshipRecord) in
            
            if success {
                guard let myRelationshipRecord = self.myRelationshipRecord else {
                    return
                }
                if let alreadyFriends = myRelationshipRecord["Friends"] {
                    let friends = alreadyFriends as! [CKReference]
                    self.dontSendRequest(friends, ref: friend.userID, completion: { (dontSend) in
                        
                        if dontSend {
                            // Already Friends
                            completion(false, nil, true, false)
                        } else {
                            if let friendRequests = relationshipRecord!["FriendRequests"] {
                                var priorRequests = friendRequests as! [CKReference]
                                self.dontSendRequest(priorRequests, ref: self.myRelationship!.userID, completion: { (dontSend) in
                                    
                                    if dontSend {
                                        // Already Requested
                                        completion(false, nil, false, true)
                                    } else {
                                        let ref = CKReference(recordID: user.userID, action: .deleteSelf)
                                        priorRequests.append(ref)
                                        relationshipRecord?.setObject(priorRequests as CKRecordValue?, forKey: "FriendRequests")
                                        self.defaultContainer?.publicCloudDatabase.save(relationshipRecord!, completionHandler: { (record, error) in
                                            
                                            if error == nil {
                                                completion(true, record, false, false)
                                            } else {
                                                print(error)
                                                completion(false, nil, false, false)
                                            }
                                        })
                                    }
                                })
                            } else {
                                let ref = CKReference(recordID: user.userID, action: .deleteSelf)
                                let refArray = [ref]
                                relationshipRecord?.setObject(refArray as CKRecordValue?, forKey: "FriendRequests")
                                self.defaultContainer?.publicCloudDatabase.save(relationshipRecord!, completionHandler: { (record, error) in
                                    
                                    if error == nil {
                                        completion(true, record, false, false)
                                    } else {
                                        print(error)
                                        completion(false, nil, false, false)
                                    }
                                })
                            }
                        }
                    })
                } else {
                    
                }
            } else {
                completion(false, nil, false, false)
            }
        }
    }


    func dontSendRequest(_ refArray: [CKReference], ref:CKReference, completion:(_ success: Bool) -> Void) {
        for person in refArray {
            if person.recordID == ref.recordID {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func saveRecordArray(_ array:[CKReference], record: CKRecord, string: String, completion:@escaping (_ success:Bool) -> Void) {
        record.setObject(array as CKRecordValue?, forKey: string)
        self.defaultContainer?.publicCloudDatabase.save(record, completionHandler: { (record, error) in
            if error == nil {
                completion(true)
            } else {
                print(error)
                completion(false)
            }
        })
    }
    
//      does the same thing as ^^ but this sets name to icloud
    func fetchUserInfoAndSetUserName(_ user: User, completion:@escaping (_ success: Bool, _ user: User?) -> Void) {
        self.fetchRecord { (success, record) in
            if success {
                
                if #available(iOS 10.0, *) {
                    self.defaultContainer?.discoverUserIdentity(withUserRecordID: user.userID, completionHandler: { (userIdentity, error) in
                        if error == nil {

                            if let firstName = userIdentity?.nameComponents?.givenName,
                                let lastName = userIdentity?.nameComponents?.familyName {
                                let fullName = "\(firstName) \(lastName)"
                                user.fullName = fullName
                                completion(true, user)
                            }
                        } else {
                            NSLog("COULDN'T FETCH USER INFO")
                            completion(false, nil)
                        }
                    })
                } else {
                    self.defaultContainer!.discoverUserInfo(withUserRecordID: user.userID) { (info, error) in
                        if error == nil {
                            
                            if let firstName = info?.displayContact?.givenName,
                                let lastName = info?.displayContact?.familyName {
                                let fullName = "\(firstName) \(lastName)"
                                user.fullName = fullName
                                completion(true, user)
                            }
                        } else {
                            NSLog("COULDN'T FETCH USER INFO")
                            completion(false, nil)
                        }
                    }
                }
            } else {
                NSLog("COULDN'T FETCH USER")
                completion(false, nil)
            }
        }
    }

//      startup app check to see if user has accepted permission
    func checkForUser(_ completion:@escaping (_ success: Bool) -> Void) {
        self.defaultContainer?.status(forApplicationPermission: .userDiscoverability, completionHandler: { (permissionStatus, error) in
            if permissionStatus == CKApplicationPermissionStatus.granted {
                self.fetchUser({ (success, user) in
                    if success {
                        self.fetchUserInfoAndSetUserName(user!, completion: { (success, user) in
                            if success {
                                self.currentUser = user
                                completion(true)
                            } else {
                                print("error fecthing user info")
                                completion(false)
                            }
                        })
                    } else {
                        print("error fetching user")
                        completion(false)
                    }
                })
            } else {
                if let error = error {
                    print(error)
                }
                completion(false)
            }
        })
        
    }
    
    func createRelationship(_ user: User, completion:@escaping (_ success: Bool, _ ref: CKReference?) -> Void) {
        let ref = CKReference(recordID: user.userID, action: .deleteSelf)
        let relationship = Relationship.init(fullName: user.fullName!, userID: ref, requests: nil, friends: nil, profilePic: nil)
        UserController.sharedInstance.myRelationship = relationship
        let record = CKRecord(recordType: "Relationship")
        
        record.setValuesForKeys(relationship.toAnyObject() as! [String: AnyObject])
        self.defaultContainer!.publicCloudDatabase.save(record, completionHandler: { (relationshipRecord, error) in
            if error == nil {
                completion(true, ref)
                UserController.sharedInstance.myRelationshipRecord = relationshipRecord
            } else {
                NSLog("ERROR: \(error?.localizedDescription)")
                completion(false, nil)
            }
        }) 
    }
    
//     MARK: Queries
    func fetchRecordWithID(_ recordID: CKRecordID, completion: ((_ record: CKRecord?, _ error: NSError?) -> Void)?) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.fetch(withRecordID: recordID) { (record, error) in
            
            if let completion = completion {
                completion(record, error as NSError?)
            }
        }
    }
    
//    fetch record by user id
    func fetchRecord(_ completion:@escaping (_ success: Bool, _ record: CKRecord?) -> Void) {
        self.defaultContainer?.fetchUserRecordID(completionHandler: { (userID, error) in
            if error == nil {
                self.defaultContainer?.privateCloudDatabase.fetch(withRecordID: userID!, completionHandler: { (record, error) in
                    if error == nil {
                        completion(true, record)
                    } else {
                        completion(false, nil)
                    }
                })
            } else {
                completion(false, nil)
            }
        })
    }
    
    func queryForMyRelationship(_ user: User, completion:@escaping (_ success: Bool, _ relationshipRecord: CKRecord?) -> Void) {
        let pred = NSPredicate(format: "FullName == %@",  user.fullName!)
        let query = CKQuery(recordType: "Relationship", predicate: pred)
        self.defaultContainer?.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if let records = records {
                if records.count != 0 {
                    for relationship in records {
                        if relationship == records.last {
                            completion(true, relationship)
                        }
                    }
                } else {
                    completion(false, nil)
                }

            } else {
                NSLog("ERROR Querying for my relationship: \(error?.localizedDescription)")
                completion(false, nil)
            }
        })
    }
    
    func queryForRelationshipByName(_ userName:String, completion:@escaping (_ success:Bool, _ relationshipRecord: CKRecord?) -> Void) {
        let pred = NSPredicate(format: "FullName == %@", userName)
        let query = CKQuery(recordType: "Relationship", predicate: pred)
        self.defaultContainer?.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error == nil {
                for relationship in records! {
                    if relationship == records?.last {
                        completion(true, relationship)
                    } else {
                        completion(false, nil)
                    }
                }
                
            } else {
                completion(false, nil)
            }
        })
    }
    
    func queryForRelationshipbyUID(_ userID: CKRecordID, completion:@escaping (_ success: Bool, _ relationshipRecord:CKRecord?) -> Void) {
        let pred = NSPredicate(format: "UserIDRef = %@", userID)
        let query = CKQuery(recordType: "Relationship", predicate: pred)
        self.defaultContainer?.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error == nil {
                for relationship in records! {
                    if relationship == records?.last {
                        completion(true, relationship)
                    }
                }
            } else {
                NSLog("Querying for relationship by UID ERROR: \(error?.localizedDescription)")
                completion(false, nil)
            }
        })
    }

    
    
    func searchAllUsers(_ searchTerm: String, completion:@escaping (_ success: Bool, _ users: [Relationship]?) -> Void) {
        var tempUsers = [Relationship]()
        let predicate = NSPredicate(format: "FullName BEGINSWITH %@", searchTerm)
        let query = CKQuery(recordType: "Relationship", predicate: predicate)
        DispatchQueue.main.async {
            self.defaultContainer?.publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let records = records {
                    for record in records {
                        
                        if let relationship = Relationship(record: record) {
                            tempUsers.append(relationship)
                        }
                        if record == records.last {
                            completion(true, tempUsers)
                        }
                    }
                } else {
                    completion(false, nil)
                    print("error searching users \(error?.localizedDescription)")
                }
            })
        }
    }
    
//     MARK: Images
    
    func grabImage(_ string: String, completion:@escaping (_ success: Bool, _ image: UIImage?) -> Void) {
        self.queryForRelationshipByName(string) { (success, relationshipRecord) in
            if success {
                if let asset = relationshipRecord!["ImageKey"] as? CKAsset {
                    let image = asset.image
                    completion(true, image)
                } else {
                    completion(false, nil)
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    func grabImageByUID(_ recordID: CKRecordID, completion:@escaping (_ success: Bool, _ image:UIImage?) -> Void) {
        queryForRelationshipbyUID(recordID) { (success, relationshipRecord) in
            if success {
                if let asset = relationshipRecord!["ImageKey"] as? CKAsset {
                    let image = asset.image
                    completion(true, image)
                } else {
                    completion(true, nil)
                }
            } else {
                completion(false, nil)
            }
            
        }
    }
    
//    TODO: subscribe when they create an account to all changes in friend requests
    func subscribeToFriendRequests(_ relationship:Relationship, completion:((_ success:Bool, _ error: NSError?) -> Void)?) {
        let recordID = relationship.userID
        let predicate = NSPredicate(format: "recordID == %@", recordID)
        ConversationController.sharedInstance.subscribe("Relationship", predicate: predicate, subscriptionID: ("\(relationship.userID)A"), contentAvailable: true, alertBody: "You have a new friend request", desiredKeys: ["FriendRequests"], options: .firesOnRecordUpdate) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(success, error)
            }
        }
    }
    
    func removeFriend(_ friend:Relationship, currentRel: Relationship, completion:@escaping (_ success: Bool) -> Void) {
        queryForRelationshipByName(friend.fullName) { (success, relationshipRecord) in
            if success {
                if relationshipRecord!["Friends"] != nil {
                    var friends = relationshipRecord!["Friends"] as! [CKReference]
                    var index: Int = 0
                    for f in friends {
                        if f != friends[0] {
                           index = index + 1
                        }
                        if f == currentRel.userID {
                            friends.remove(at: index)
                        }
                    }
                    self.saveRecordArray(friends, record: relationshipRecord!, string: "Friends", completion: { (success) in
                        if success {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                }
            }
        }
    }
    
//    MARK: Alerts
    
    func sendAlert(convoRef: CKReference, convoName:String) {
        let array = convoName.components(separatedBy: ", ")
        
        for name in array {
            self.queryForRelationshipByName(name, completion: { (success, relationshipRecord) in
                guard let relationshipRecord = relationshipRecord else {
                    return
                }
                if success {
                    var alerts = relationshipRecord.object(forKey: "Alerts") as? [CKReference] ?? []
                    for alert in alerts {
                        if alert != convoRef {
                           alerts.append(convoRef)
                        }
                    }
                    
                    self.saveRecordArray(alerts, record: relationshipRecord, string: "Alerts", completion: { (success) in
                        
                    })
                    
                }
            })
        }
    }
    
    func fetchAlerts(convoRef:CKReference) {
        let alerts = UserController.sharedInstance.myRelationshipRecord?.object(forKey: "Alerts") as? [CKReference] ?? []
        var int = -1
        for alert in alerts {
            int = int + 1
            if alert == convoRef {
                UserController.sharedInstance.myRelationship?.alerts.append(alert)
            }
        }
        
    }
    
    func fetchRelationship(relationshipRef:CKReference) {
        
    }
    
}










