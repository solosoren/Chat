//
//  InitialLoadingView.swift
//  Chat
//
//  Created by Soren Nelson on 7/5/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit


class InitialLoadingView: UIViewController {
    
    var friends: [Relationship] = []
    var requests: [Relationship] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBar()
        //        self.performSegueWithIdentifier("loginSegue", sender: self)
        
//      TODO: Clean the FUCK up  
        
        UserController.sharedInstance.checkForUser { (success) in
            if success {
                if UserController.sharedInstance.currentUser != nil {
                    UserController.sharedInstance.queryForMyRelationship({ (success, relationshipRecord) in
                        if success {
                            
                            if let relationshipRecord = relationshipRecord {
                                UserController.sharedInstance.myRelationshipRecord = relationshipRecord
                                let myRelationship = Relationship(fullName: relationshipRecord["FullName"] as! String, userID: relationshipRecord["UserIDRef"] as! CKReference, requests: relationshipRecord["FriendRequests"] as? [CKReference], friends: relationshipRecord["Friends"] as? [CKReference])
                                UserController.sharedInstance.myRelationship = myRelationship
                                
                                if myRelationship.requests! != [] {
                                    for request in myRelationship.requests! {
                                        UserController.sharedInstance.queryForRelationshipbyUID(request.recordID) { (success, relationshipRecord) in
                                            if let relationshipRecord = relationshipRecord {
                                                let requestRelationship = Relationship(fullName: relationshipRecord["FullName"] as! String, userID: relationshipRecord["UserIDRef"] as! CKReference, requests: relationshipRecord["FriendRequests"] as? [CKReference], friends: relationshipRecord["Friends"] as? [CKReference])
                                                self.requests += [requestRelationship]
                                            } else {
                                                self.requests += []
                                            }
                                        }
                                    }
                                } else {
                                    self.requests = []
                                    }
                                if myRelationship.friends! != [] {
                                    for friend in myRelationship.friends! {
                                        UserController.sharedInstance.queryForRelationshipbyUID(friend.recordID, completion: { (success, relationshipRecord) in
                                            if let relationshipRecord = relationshipRecord {
                                                let friendRelationship = Relationship(fullName: relationshipRecord["FullName"] as! String, userID: relationshipRecord["UserIDRef"] as! CKReference, requests: relationshipRecord["FriendRequests"] as? [CKReference], friends: relationshipRecord["Friends"] as? [CKReference])
                                                self.friends += [friendRelationship]
                                                dispatch_async(dispatch_get_main_queue(), { 
                                                    self.performSegueWithIdentifier("initialLoad", sender: self)
                                                })
                                            } else {
                                                self.friends = []
                                                dispatch_async(dispatch_get_main_queue(), {
                                                    self.performSegueWithIdentifier("initialLoad", sender: self)
                                                })
                                            }
                                        })
                                    }
                                } else {
                                    self.friends = []
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.performSegueWithIdentifier("initialLoad", sender: self)
                                    })
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.performSegueWithIdentifier("loginSegue", sender: self)
                                })
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.performSegueWithIdentifier("loginSegue", sender: self)
                            })
                        }
                    })
                } else {
                    print("Current user isn't set")
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                })
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "initialLoad" {
            let destinationVC = segue.destinationViewController as! HomeViewController
            destinationVC.myRequests = self.requests
            destinationVC.myFriends = self.friends
        }
    }


}
