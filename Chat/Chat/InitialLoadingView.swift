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
    
//    TODO: clean up self's
//    TODO: fix all else error
    
    var friends: [Relationship] = []
    var requests: [Relationship] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialNavBar()
        //        self.performSegueWithIdentifier("loginSegue", sender: self)
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
//      TODO: Clean the FUCK up
        
        UserController.sharedInstance.checkForUser { (success) in
            if success {
                NSLog("SSSSSSSSSSSSS: 1")
                if UserController.sharedInstance.currentUser != nil {
                    UserController.sharedInstance.queryForMyRelationship({ (success, relationshipRecord) in
                        if success {
                            NSLog("SSSSSSSSSSSSS: 2")
                            if let relationshipRecord = relationshipRecord {
                                UserController.sharedInstance.myRelationshipRecord = relationshipRecord
                                let myRelationship = Relationship(fullName: relationshipRecord["FullName"] as! String, userID: relationshipRecord["UserIDRef"] as! CKReference, requests: relationshipRecord["FriendRequests"] as? [CKReference], friends: relationshipRecord["Friends"] as? [CKReference])
                                UserController.sharedInstance.myRelationship = myRelationship
                                self.initiallyGrabRequests(myRelationship, completion: { (success) in
                                    if success {
                                        NSLog("SSSSSSSSSSSSS: 3")
                                        self.initiallyGrabFriends(myRelationship, completion: { (success) in
                                            if success {
                                                NSLog("SSSSSSSSSSSSS: 4")
                                                dispatch_async(dispatch_get_main_queue(), { 
                                                    indicator.stopAnimating()
                                                    self.performSegueWithIdentifier("initialLoad", sender: self)
                                                })
                                            } else {
                                                NSLog("SSSSSSSSSSSSS: 5")
                                            }
                                        })
                                    } else {
                                        NSLog("SSSSSSSSSSSSS: 6")
                                    }
                                })
                                } else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    indicator.stopAnimating()
                                    self.performSegueWithIdentifier("loginSegue", sender: self)
                                })
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                indicator.stopAnimating()
                                self.performSegueWithIdentifier("loginSegue", sender: self)
                            })
                        }
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        indicator.stopAnimating()
                        self.performSegueWithIdentifier("loginSegue", sender: self)
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    indicator.stopAnimating()
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
    
    func initiallyGrabRequests(relationship:Relationship, completion:(success: Bool) -> Void) {
        
        if relationship.requests! != [] {
            NSLog("SSSSSSSSSSSSS: 7")
            for request in relationship.requests! {
                UserController.sharedInstance.queryForRelationshipbyUID(request.recordID) { (success, relationshipRecord) in
                    if let relationshipRecord = relationshipRecord {
                        NSLog("SSSSSSSSSSSSS: 8")
                        let requestRelationship = Relationship(fullName: relationshipRecord["FullName"] as! String, userID: relationshipRecord["UserIDRef"] as! CKReference, requests: relationshipRecord["FriendRequests"] as? [CKReference], friends: relationshipRecord["Friends"] as? [CKReference])
                        self.requests += [requestRelationship]
                        if request == relationship.requests!.last {
                            NSLog("SSSSSSSSSSSSS: 9")
                            completion(success: true)
                        }
                    } else {
                        self.requests = []
                        if request == relationship.requests!.last {
                            completion(success: true)
                        }
                    }
                }
            }
        } else {
            self.requests = []
            completion(success: true)
        }
    }
    
    func initiallyGrabFriends(relationship:Relationship, completion:(success: Bool) -> Void) {
        
        if relationship.friends! != [] {
            NSLog("SSSSSSSSSSSSS: 10")
            for friend in relationship.friends! {
                UserController.sharedInstance.queryForRelationshipbyUID(friend.recordID, completion: { (success, relationshipRecord) in
                    if success {
                        NSLog("SSSSSSSSSSSSS: 11")
                        let friendRelationship = Relationship(fullName: relationshipRecord!["FullName"] as! String, userID: relationshipRecord!["UserIDRef"] as! CKReference, requests: relationshipRecord!["FriendRequests"] as? [CKReference], friends: relationshipRecord!["Friends"] as? [CKReference])
                        self.friends += [friendRelationship]
                        if friend == relationship.friends?.last {
                            completion(success: true)
                            NSLog("SSSSSSSSSSSSS: 12")
                        }
                    } else {
                        self.friends = []
                        if friend == relationship.friends?.last {
                            completion(success: true)
                            NSLog("SSSSSSSSSSSSS: 13")

                        }
                    }
                })
            }
        } else {
            self.friends = []
            completion(success: true)
            NSLog("SSSSSSSSSSSSS: 14")
        }
    }


}
