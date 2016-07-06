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
    
    var requests: [CKReference]?
    var names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBar()
        //        self.performSegueWithIdentifier("loginSegue", sender: self)
        
        UserController.sharedInstance.checkForUser { (success) in
            if success {
                if UserController.sharedInstance.currentUser != nil {
                    UserController.sharedInstance.queryForMyRelationship({ (success, relationshipRecord) in
                        if success {
                            if let relationshipRecord = relationshipRecord {
                                UserController.sharedInstance.myRelationshipRecord = relationshipRecord
                                if relationshipRecord["FriendRequests"] as! [CKReference] != [] {
                                    self.requests = relationshipRecord["FriendRequests"] as? [CKReference]
                                    if self.requests!.count != 0 {
                                        for request in self.requests! {
                                            UserController.sharedInstance.queryForRelationshipbyUID(request.recordID) { (success, relationshipRecord) in
                                                if let relationshipRecord = relationshipRecord {
                                                    let name = relationshipRecord["FullName"] as! String
                                                    self.names += [name]
                                                    if request == self.requests?.last {
                                                        dispatch_async(dispatch_get_main_queue(), {
                                                            self.performSegueWithIdentifier("initialLoad", sender: self)
                                                        })
                                                    }
                                                } else {
                                                    self.requests = []
                                                    dispatch_async(dispatch_get_main_queue(), { 
                                                        self.performSegueWithIdentifier("initialLoad", sender: self)
                                                    })
                                                }
                                            }
                                        }
                                    } else {
                                        self.requests = []
                                        dispatch_async(dispatch_get_main_queue(), { 
                                            self.performSegueWithIdentifier("initialLoad", sender: self)
                                        })
                                    }
                                } else {
                                    self.requests = []
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
            destinationVC.requests = self.requests
            destinationVC.namesOfRequesters = self.names
            
        }
    }


}
