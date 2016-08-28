//
//  HomeTableViewController.swift
//  Chat
//
//  Created by Soren Nelson on 3/29/16.
//  Copyright © 2016 SORN. All rights reserved.
//  

import CloudKit
import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var contactView: UIView!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let darkView = UIView()
    
    var changedConvo: Conversation?
    var convoImage: CKAsset?
    var requests: [CKReference]?
    var myRequests: [Relationship]?
    var numberInSection:Int?
    var myFriends: [Relationship]?
    var myConversations: [Conversation]?
    var convoRecords: [CKRecord]?
    var passOnConvo: Conversation?
    var convoRecord: CKRecord?
    var contactRelationship: Relationship?
    var addContactIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        setNavBar()
        tableView.reloadData()
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
 
// MARK: Segmented Control
    
    @IBAction func segmentedControlChanged(sender: AnyObject) {
        tableView.reloadData()
    }

    
// MARK: TableView
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == 0 {
            return 80
            
        } else {
            if indexPath.row == numberInSection {
                if let myFriends = myFriends {
                    if myFriends.count % 3 == 1 {
                        let contactCellHeight = CGFloat(145 * ((myFriends.count + 2)/3)) + 30
                        return contactCellHeight
                    } else if myFriends.count % 3 == 2 {
                        let contactCellHeight = CGFloat(145 * ((myFriends.count + 1)/3)) + 30
                        return contactCellHeight
                    } else {
                        let contactCellHeight = CGFloat(145 * (myFriends.count/3)) + 30
                        return contactCellHeight
                    }
                } else {
                    return 175
                }
                
                
            } else {
                return 87
            }
        }
    }



//  TODO: create sections ??

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        see if pass on convo works with multiple convo's
        if segmentedControl.selectedSegmentIndex == 0 {
            let convoCell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as! HomeMessageCell
            let convo = myConversations![indexPath.row]
            
            convoCell.messageText.text = convo.lastMessage?.messageText
            var groupName = convo.convoName
            if let myName = UserController.sharedInstance.myRelationship?.fullName {
                if let range = groupName?.rangeOfString("\(myName), ") {
                    groupName?.removeRange(range)
                    convoCell.userName.text = groupName
                }
                if let range = groupName?.rangeOfString(", \(myName)") {
                    groupName?.removeRange(range)
                    convoCell.userName.text = groupName
                }
            } else {
                convoCell.userName.text = "..."
            }
            if let time = convo.lastMessage?.time {
                convoCell.messageTime.text = time
            }
            if let userPic = convo.lastMessage?.userPic {
                convoCell.userImage.image = userPic
            }
            return convoCell
            
        } else {
            
            if indexPath.row == numberInSection {
                let contactCell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactTableViewCell
                return contactCell
                
            } else {
                let notificationCell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! NotificationCell
                
                notificationCell.acceptButton.tag = indexPath.row
                notificationCell.declineButton.tag = indexPath.row
                if let myRequests = myRequests {
                    if myRequests.count != 0 {
                        let index = indexPath.row
                        let name = myRequests[index].fullName
                        notificationCell.inviteLabel.text = "\(name) sent you a friend request"
                        if let asset = myRequests[index].profilePic {
                            notificationCell.profilePic.image = asset.image
                        }
                    } else {
                        
                    }
                } else {
                    
                }
                return notificationCell
            }
        }
    }
    
    func returnLastMessage(conversation: Conversation, profilePic: CKAsset?) {
        changedConvo = conversation
        convoImage = profilePic
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if myConversations?.count != 0 {
                if let myConversations = myConversations {
                    return myConversations.count
                } else {
                    return 0
                }
            } else {
                return 0
            }
            
        } else {
            if let requests = self.myRequests {
                if requests.count == 0 {
                    self.numberInSection = 0
                    return 1
                    
                } else {
                    let number = requests.count + 1
                    self.numberInSection = number - 1
                    return number
                }
            } else {
                self.numberInSection = 0
                return 1
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            performSegueWithIdentifier("messageSegue", sender: self)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messageSegue" {
            let destinationVC = segue.destinationViewController as! MessagingViewController
            if let convoIndex = tableView.indexPathForSelectedRow?.row {
                destinationVC.convoRecord = self.convoRecords![convoIndex]
                if let myConversation = myConversations?[convoIndex] {
                    ConversationController.sharedInstance.grabMessages(myConversation, completion: { (error, conversation, theMessages) in
                        if let error = error {
                            destinationVC.conversation = conversation
                            destinationVC.conversation?.messages = []
                            destinationVC.conversation?.theMessages = []
                            print("ERROR: \(error)")
                        } else {
                            if let messages = myConversation.messages,
                                let theMessages = theMessages {
                                var passOnConversation = Conversation(convoName: conversation?.convoName, users: (conversation?.users)!, messages: messages)
                                passOnConversation.theMessages = theMessages
                                destinationVC.conversation?.theMessages = theMessages
                                destinationVC.conversation?.messages = messages
                                destinationVC.conversation = passOnConversation
                                dispatch_async(dispatch_get_main_queue(), { 
                                    destinationVC.tableView.reloadData()

                                })
                            }
                        }
                    })
                } else {
                    print("ERROR")
                }
            } else {
                print("ERROR")
            }
            
        } else if segue.identifier == "newMessageSegue" {
            let destinationVC = segue.destinationViewController as! MessagingViewController
            destinationVC.conversation = self.passOnConvo
            destinationVC.convoRecord = self.convoRecord
        } else if segue.identifier == "addToGroup" {
            let navController = segue.destinationViewController as! UINavigationController
            let destinationVC = navController.topViewController as! CreateGroupViewController
            destinationVC.contacts = self.myFriends
            destinationVC.initialContact = self.contactRelationship
        }
        
        
    }
    
    
// MARK: Friend Request actions
    
    @IBAction func acceptButtonTapped(sender: AnyObject) {
        if myRequests != nil {
            let requester = myRequests?[sender.tag]
            myRequests!.removeAtIndex(sender.tag)
            guard let myRequests = myRequests else {
                return
            }
            for request in myRequests {
                let ref = CKReference(recordID: request.userID.recordID, action: .DeleteSelf)
                requests? += [ref]
            }
            if requests == nil {
                requests = []
            }
            UserController.sharedInstance.saveRecordArray(self.requests!, record: UserController.sharedInstance.myRelationshipRecord!, string: "FriendRequests") { (success) in
                if success {
                    if UserController.sharedInstance.myRelationship?.friends != nil {
                        var friends = UserController.sharedInstance.myRelationship?.friends
                        let ref = CKReference(recordID: requester!.userID.recordID, action: .DeleteSelf)
                        friends? += [ref]
                        UserController.sharedInstance.saveRecordArray(friends!, record: UserController.sharedInstance.myRelationshipRecord!, string: "Friends", completion: { (success) in
                            if success {
                                UserController.sharedInstance.acceptRequest(UserController.sharedInstance.currentUser!, friend: requester!, completion: { (success, record) in
                                    if success {
                                        let relationship = Relationship(fullName: record!["FullName"] as! String, userID: record!["UserIDRef"] as! CKReference, requests: nil, friends: nil, profilePic: record!["ImageKey"] as? CKAsset)
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.myFriends! += [relationship]
                                            self.tableView.reloadData()
                                            let indexPath = NSIndexPath(forRow: self.numberInSection!, inSection: 0)
                                            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactTableViewCell
                                            cell.collectionView.reloadData()
                                        })
                                    } else {
                                        dispatch_async(dispatch_get_main_queue(), { 
                                            let alert = UIAlertController(title: "Error", message: "Couldn't save friends friends", preferredStyle: .Alert)
                                            let action = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) in
                                                return
                                            })
                                            alert.addAction(action)
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })
                                    }
                                })
                            } else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    let alert = UIAlertController(title: "Error", message: "Couldn't save friends friends", preferredStyle: .Alert)
                                    let action = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) in
                                        return
                                    })
                                    alert.addAction(action)
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    } else {
                        UserController.sharedInstance.sendRequest(UserController.sharedInstance.currentUser!, friend: requester!, completion: { (success, record) in
                            if success {
                                let relationship = Relationship(fullName: record!["FullName"] as! String, userID: record!["UserIDRef"] as! CKReference, requests: nil, friends: nil, profilePic: record!["ImageKey"] as? CKAsset)
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    self.myFriends! += [relationship]
                                    self.tableView.reloadData()
                                    let indexPath = NSIndexPath(forRow: self.numberInSection!, inSection: 0)
                                    let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactTableViewCell
                                    cell.collectionView.reloadData()
                                })
                            } else {
                                dispatch_async(dispatch_get_main_queue(), {
                                    let alert = UIAlertController(title: "Error", message: "Couldn't save friends friends", preferredStyle: .Alert)
                                    let action = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) in
                                        return
                                    })
                                    alert.addAction(action)
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                            }
                        })
                        
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: "Error", message: "Couldn't remove requests", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "Okay", style: .Cancel, handler: { (action) in
                            return
                        })
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }

    @IBAction func declineButtonTapped(sender: AnyObject) {
        myRequests?.removeAtIndex(sender.tag)
        for request in self.myRequests! {
            let ref = CKReference(recordID: request.userID.recordID, action: .DeleteSelf)
            requests? += [ref]
        }
        if let requesters = requests {
            UserController.sharedInstance.saveRecordArray(requesters, record: UserController.sharedInstance.myRelationshipRecord!, string: "FriendRequests") { (success) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                } else {
                    NSLog("Didn't save friend requests")
                }
            }
        } else {
            UserController.sharedInstance.saveRecordArray([], record: UserController.sharedInstance.myRelationshipRecord!, string: "FriendRequests") { (success) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                } else {
                    NSLog("Didn't save friend requests")
                }
            }
            NSLog("No Requesters")
            
        }
    }

    
    
// MARK: Collection View
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCellWithReuseIdentifier("contactItem", forIndexPath: indexPath) as! ContactCollectionCell
        let index = indexPath.item
        item.contactName.text = myFriends![index].fullName
        if let asset = myFriends![index].profilePic {
            item.contactImage.image = asset.image
        } else {
            item.contactImage.image = UIImage.init(named: "Contact")
        }
        return item
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let myFriends = myFriends {
            return myFriends.count
        } else {
            return 0
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width:(self.view.bounds.width / 3) - 20, height:143)
        return size
    }
    
  
//    
//    
//    
//    TODO:
    var index:Int?
    @IBOutlet var bigProfilePic: UIImageView!
    @IBOutlet var bigName: UILabel!

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        contactView.center.x = view.center.x
        contactView.center.y = view.center.y - 40
        bigName.text = myFriends![indexPath.item].fullName
        contactRelationship = myFriends![indexPath.item]
        index = indexPath.item
        
        if let asset = myFriends![indexPath.item].profilePic {
            bigProfilePic.image = asset.image
        }
        darkView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        darkView.backgroundColor = UIColor.blackColor()
        darkView.alpha = 0.5
        
        view.addSubview(darkView)
        view.addSubview(contactView)
        
    }
    
// MARK: Contact View
    
    @IBAction func contactDismissButtonTapped(sender: AnyObject) {
        contactView.removeFromSuperview()
        darkView.removeFromSuperview()
    }
    
    @IBAction func addToGroupButtonPressed(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.contactView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            self.performSegueWithIdentifier("addToGroup", sender: self)
            
//            was commented out??
            
            let destinationVC = CreateGroupViewController()
            destinationVC.contacts = self.myFriends
            destinationVC.initialContact = self.contactRelationship
        }
    }
    
    @IBAction func removeFriendButtonPressed(sender: AnyObject) {
        myFriends?.removeAtIndex(index!)
        UserController.sharedInstance.myRelationship?.friends? = []
        for friend in myFriends! {
            let ref = CKReference(recordID: friend.userID.recordID, action: .DeleteSelf)
            UserController.sharedInstance.myRelationship?.friends? += [ref]
        }
        UserController.sharedInstance.saveRecordArray((UserController.sharedInstance.myRelationship?.friends)!, record: UserController.sharedInstance.myRelationshipRecord!, string: "Friends") { (success) in
            if success {
                UserController.sharedInstance.removeFriend(self.contactRelationship!, currentRel: UserController.sharedInstance.myRelationship!, completion: { (success) in
                    if success {
                        if self.myFriends?.count != 0 {
                            dispatch_async(dispatch_get_main_queue(), {
                                let indexPath = NSIndexPath(index: self.numberInSection!)
                                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactTableViewCell
                                self.contactView.removeFromSuperview()
                                self.darkView.removeFromSuperview()
                                cell.collectionView.reloadData()
                            })
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { 
                                self.contactView.removeFromSuperview()
                                self.darkView.removeFromSuperview()
                            })
                        }
                    } else {
                        let alertController = UIAlertController(title: "Uh oh", message: "There was an error removing your friend.", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                        alertController.addAction(action)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.presentViewController(alertController, animated: true, completion: nil)
                        })
                    }
                })
                
            } else {
                let alertController = UIAlertController(title: "Uh oh", message: "There was an error removing your friend.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alertController.addAction(action)
                dispatch_async(dispatch_get_main_queue(), { 
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    
    @IBAction func sendMessageButtonTapped(sender: AnyObject) {
        let myRelationship = UserController.sharedInstance.myRelationship
//        TODO: fix name of convo
        let conversation = Conversation.init(convoName: "\((myRelationship?.fullName)!), \((contactRelationship?.fullName)!)", users: [myRelationship!.userID, contactRelationship!.userID], messages: [])
        ConversationController.createConversation(conversation) { (success, record) in
            if success {
                self.convoRecord = record
                self.passOnConvo = conversation
                if self.myConversations?.count == 0 {
                    self.myConversations = [conversation]
                } else {
                    self.myConversations! += [conversation]
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.contactView.removeFromSuperview()
                    self.darkView.removeFromSuperview()
                    self.performSegueWithIdentifier("newMessageSegue", sender: self)

                })
                
            } else {
                print("Not this time")
            }
            
        }
    }
}

extension UIViewController {
    
    func setNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 0, green: 0.384, blue: 0.608, alpha: 1.0)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let iconImage = UIImage.init(named: "Little White Icon")
        let imageView = UIImageView(frame: CGRect(x: 0, y: -5, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = iconImage
        navigationItem.titleView = imageView
    }
}


