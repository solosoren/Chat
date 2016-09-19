//
//  InitialLoadingView.swift
//  Chat
//
//  Created by Soren Nelson on 7/5/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

class InitialLoadingView: UIViewController {

//    TODO: clean up code
    
        // NOT WORKING -------
//    all convos not loading
//    accept button crashing
    
    
        // User
//TODO:      subscribe to friend requests
    
        // Messaging
//          conversation messages ordered by date!

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
        navigationController?.isNavigationBarHidden = true
        
        //        self.performSegueWithIdentifier("loginSegue", sender: self)
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
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
                                if let myRelationship = Relationship(record: relationshipRecord) {
                                    UserController.sharedInstance.myRelationship = myRelationship
//                                    ConversationController.sharedInstance.fetchNotificationChanges({ (success) in
                                        if success {
                                            self.initiallyGrabRequests(myRelationship, completion: { (success) in
                                                if success {
                                                    self.initiallyGrabFriends(myRelationship, completion: { (success) in
                                                        if success {
                                                            self.initiallyGrabConvos({ (success) in
                                                                if success {
                                                                    DispatchQueue.main.async(execute: {
                                                                        indicator.stopAnimating()
                                                                        self.performSegue(withIdentifier: "initialLoad", sender: self)
                                                                    })
                                                                } else {
                                                                    NSLog("Couldn't grab initial conversations")
                                                                    DispatchQueue.main.async(execute: {
                                                                        indicator.stopAnimating()
                                                                        self.performSegue(withIdentifier: "initialLoad", sender: self)
                                                                    })
                                                                }
                                                            })
                                                        } else {
                                                            //                                                figure out
                                                            self.initiallyGrabConvos({ (success) in
                                                                if success {
                                                                    DispatchQueue.main.async(execute: {
                                                                        indicator.stopAnimating()
                                                                        self.performSegue(withIdentifier: "initialLoad", sender: self)
                                                                    })
                                                                } else {
                                                                    NSLog("Couldn't grab initial conversations")
                                                                    DispatchQueue.main.async(execute: {
                                                                        indicator.stopAnimating()
                                                                        self.performSegue(withIdentifier: "initialLoad", sender: self)
                                                                    })
                                                                }
                                                            })
                                                        }
                                                    })
                                                } else {
                                                    //                                        figure out
                                                    self.initiallyGrabConvos({ (success) in
                                                        if success {
                                                            DispatchQueue.main.async(execute: {
                                                                indicator.stopAnimating()
                                                                self.performSegue(withIdentifier: "initialLoad", sender: self)
                                                            })
                                                        } else {
                                                            NSLog("Couldn't grab initial conversations")
                                                            DispatchQueue.main.async(execute: {
                                                                indicator.stopAnimating()
                                                                self.performSegue(withIdentifier: "initialLoad", sender: self)
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
//                                    })
                                } else {
                                    DispatchQueue.main.async(execute: {
                                        indicator.stopAnimating()
                                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                                    })
                                }
                            } else {
                                print("right hur")
                            }
                        } else {
                            DispatchQueue.main.async(execute: {
                                indicator.stopAnimating()
                                self.performSegue(withIdentifier: "loginSegue", sender: self)
                            })
                        }
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        indicator.stopAnimating()
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                    })
                }
            } else {
                DispatchQueue.main.async(execute: {
                    indicator.stopAnimating()
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                })
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "initialLoad" {
            let destinationVC = segue.destination as! HomeViewController
            destinationVC.myRequests = requests
            
            let sortedFriends = friends.sorted { $0.fullName < $1.fullName }
            destinationVC.myFriends = sortedFriends
            
            var convosWithMessages: [Conversation] = []
            var convos: [Conversation] = []
            var sortedConvos:[Conversation] = []
            
            for convo in conversations {
                if convo.lastMessage != nil {
                    convosWithMessages.append(convo)
                    if convo.convoName == conversations.last?.convoName {
                        sortedConvos = convosWithMessages.sorted { $0.lastMessage!.time! > $1.lastMessage!.time! }
                    }
                } else {
                    convos.append(convo)
                }
            }
            convos.append(contentsOf: sortedConvos)
            destinationVC.myConversations = convos
            
            var sortedRecords:[CKRecord] = []
            
            for c in convos {
                for cr in convoRecords {
                    if c.ref == cr.recordID {
                        sortedRecords.append(cr)
                    }
                }
            }
            destinationVC.convoRecords = sortedRecords
        }
    }
    
    func initiallyGrabRequests(_ relationship:Relationship, completion:@escaping (_ success: Bool) -> Void) {
        if relationship.requests == nil {
            self.requests = []
            completion(true)
        } else if relationship.requests! != [] {
            for request in relationship.requests! {
                UserController.sharedInstance.queryForRelationshipbyUID(request.recordID) { (success, relationshipRecord) in
                    if let relationshipRecord = relationshipRecord {
                        let requestRelationship = Relationship(record:relationshipRecord)
                        self.requests += [requestRelationship!]
                        if self.requests.count == relationship.requests?.count {
                            completion(true)
                        }
                    } else {
                        self.requests = []
                            completion(true)
                    }
                }
            }
        } else {
            self.requests = []
            completion(true)
        }
    }
    
    func initiallyGrabFriends(_ relationship:Relationship, completion:@escaping (_ success: Bool) -> Void) {
        if relationship.friends == nil {
            self.friends = []
            completion(true)
        } else if relationship.friends! != [] {
            for friend in relationship.friends! {
                UserController.sharedInstance.queryForRelationshipbyUID(friend.recordID, completion: { (success, relationshipRecord) in
                    if success {
                        let friendRelationship = Relationship(record:relationshipRecord!)
                        self.friends += [friendRelationship!]
                        
                        if self.friends.count == relationship.friends?.count {
                            completion(true)
                        }
    
                    } else {
                        self.friends = []
                        completion(true)
                        
                    }
                })
            }
        } else {
            self.friends = []
            completion(true)
        }
    }
    
    func initiallyGrabConvos(_ completion:@escaping (_ success: Bool) -> Void) {
        ConversationController().grabUserConversations(UserController.sharedInstance.myRelationship!) { (success, conversations, convoRecords) in
            if success {
                self.conversations = conversations!
                self.convoRecords = convoRecords!
                completion(true)
            } else {
                self.conversations = []
//                throw error
                completion(true)
            }
        }
    }


}
