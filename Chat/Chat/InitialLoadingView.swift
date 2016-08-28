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

//    TODO: clean up code
    
        // NOT WORKING -------
//    all convos not loading
//    accept button crashing
//    accept request not saving friends friends
    
    
        // User
//TODO:          skip login
//TODO:      subscribe to friend requests
    
        // Messaging
//          conversation messages ordered by date!!!!!!

        // Testing
//-          accept request button tapped
//-          create group save button tapped segue to messaging view
//           check out if add contact vc photos work with a bunch of contacts
    
//    fix friend request and conversation to just check if subscribed?
    
    
    
    var friends: [Relationship] = []
    var requests: [Relationship] = []
    var conversations: [Conversation] = []
    var convoRecords: [CKRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        
        //        self.performSegueWithIdentifier("loginSegue", sender: self)
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
                
        UserController.sharedInstance.checkForUser { (success) in
            if success {
                if let me = UserController.sharedInstance.currentUser {
                    UserController.sharedInstance.queryForMyRelationship(me, completion: { (success, relationshipRecord) in
                        if success {
                            if let relationshipRecord = relationshipRecord {
                                UserController.sharedInstance.myRelationshipRecord = relationshipRecord
                                let myRelationship = Relationship(record: relationshipRecord)
                                UserController.sharedInstance.myRelationship = myRelationship
                                
                                self.initiallyGrabRequests(myRelationship!, completion: { (success) in
                                    if success {
                                        self.initiallyGrabFriends(myRelationship!, completion: { (success) in
                                            if success {
                                                self.initiallyGrabConvos({ (success) in
                                                    if success {
                                                        dispatch_async(dispatch_get_main_queue(), {
                                                            indicator.stopAnimating()
                                                            self.performSegueWithIdentifier("initialLoad", sender: self)
                                                        })
                                                    } else {
                                                        NSLog("Couldn't grab initial conversations")
                                                    }
                                                })
                                            } else {
                                                
//                                                figure out
                                            }
                                        })
                                    } else {
                                        
//                                        figure out
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
            destinationVC.myConversations = self.conversations
            destinationVC.convoRecords = self.convoRecords
        }
    }
    
    func initiallyGrabRequests(relationship:Relationship, completion:(success: Bool) -> Void) {
        
//        UserController.sharedInstance.subscribeToFriendRequests(relationship) { (success, error) in
//            if success {
//                print("it worked")
//            } else {
//                print("ERROR \(error)")
//            }
//        }
        
        if relationship.requests == nil {
            self.requests = []
            completion(success: true)
        } else if relationship.requests! != [] {
            for request in relationship.requests! {
                UserController.sharedInstance.queryForRelationshipbyUID(request.recordID) { (success, relationshipRecord) in
                    if let relationshipRecord = relationshipRecord {
                        let requestRelationship = Relationship(fullName: relationshipRecord["FullName"] as! String, userID: relationshipRecord["UserIDRef"] as! CKReference, requests: nil, friends: nil, profilePic: relationshipRecord["ImageKey"] as? CKAsset)
                        self.requests += [requestRelationship]
                        if request == relationship.requests!.last {
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
        
        if relationship.friends == nil {
            self.friends = []
            completion(success: true)
        } else if relationship.friends! != [] {
            for friend in relationship.friends! {
                UserController.sharedInstance.queryForRelationshipbyUID(friend.recordID, completion: { (success, relationshipRecord) in
                    if success {
                        let friendRelationship = Relationship(fullName: relationshipRecord!["FullName"] as! String, userID: relationshipRecord!["UserIDRef"] as! CKReference, requests: nil, friends: nil, profilePic: relationshipRecord!["ImageKey"] as? CKAsset)
                        self.friends += [friendRelationship]
                        
                        if friend == relationship.friends?.last {
                            completion(success: true)
                        }
                        
                    } else {
                        self.friends = []
                        if friend == relationship.friends?.last {
                            completion(success: true)

                        }
                    }
                })
            }
        } else {
            self.friends = []
            completion(success: true)
        }
    }
    
    func initiallyGrabConvos(completion:(success: Bool) -> Void) {
        ConversationController().grabUserConversations(UserController.sharedInstance.myRelationship!) { (success, conversations, convoRecords) in
            if success {
                self.conversations = conversations!
                self.convoRecords = convoRecords!
                completion(success: true)
            } else {
                self.conversations = []
//                throw error
                completion(success: true)
            }
        }
    }


}
