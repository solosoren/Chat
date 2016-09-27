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
    
    @IBOutlet var messageContactViewButton: UIButton!
    @IBOutlet var contactView: UIView!
    @IBOutlet var removeFriendContactViewXConstraint: NSLayoutConstraint!
    @IBOutlet var removeFriendContactViewButton: UIButton!
    @IBOutlet var addToGroupContactViewXConstraint: NSLayoutConstraint!
    @IBOutlet var addToGroupContactViewButton: UIButton!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let darkView = UIView()
    let leftSwipe = UISwipeGestureRecognizer()
    let rightSwipe = UISwipeGestureRecognizer()
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
    var demo = false
    var skippedLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        if skippedLogin {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        setNavBar()
        leftSwipe.addTarget(self, action: #selector(HomeViewController.leftSwiped))
        leftSwipe.direction = .left
        tableView.addGestureRecognizer(leftSwipe)
        rightSwipe.addTarget(self, action: #selector(HomeViewController.rightSwiped))
        rightSwipe.direction = .right
        tableView.addGestureRecognizer(rightSwipe)
        tableView.isUserInteractionEnabled = true
        tableView.reloadData()
    }
    
    @IBAction func unwindToHome(_ segue: UIStoryboardSegue) {}
 
// MARK: Segmented Control
    
    @IBAction func segmentedControlChanged(_ sender: AnyObject) {
        tableView.reloadData()
    }
    
    func rightSwiped() {
        if segmentedControl.selectedSegmentIndex == 1 {
            segmentedControl.selectedSegmentIndex = 0
            tableView.isScrollEnabled = true
        }
        tableView.reloadData()
    }
    
    func leftSwiped() {
        if segmentedControl.selectedSegmentIndex == 0 {
            segmentedControl.selectedSegmentIndex = 1
        }
        tableView.reloadData()
    }

    
// MARK: TableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == 0 {
            tableView.isScrollEnabled = true
            return 80
            
        } else {
            var contactCellHeight:CGFloat
            var requestHeight:CGFloat
            if let notifications = myRequests?.count {
                contactCellHeight = view.frame.size.height
                requestHeight = (CGFloat(notifications) * 72)
            } else {
                contactCellHeight = view.frame.size.height
                requestHeight = 0
            }
            if (indexPath as NSIndexPath).row == numberInSection {
                if let myFriends = myFriends {
                    if myFriends.count != 0 {
                        if myFriends.count % 3 == 1 {
                            contactCellHeight = CGFloat(150 * ((myFriends.count + 2)/3)) + 30
                            let height = contactHeight(contactCellHeight, requestHeight: requestHeight)
                            return height
                        } else if myFriends.count % 3 == 2 {
                            contactCellHeight = CGFloat(150 * ((myFriends.count + 1)/3)) + 30
                            let height = contactHeight(contactCellHeight, requestHeight: requestHeight)
                            return height
                        } else {
                            contactCellHeight = CGFloat(150 * (myFriends.count/3)) + 30
                            let height = contactHeight(contactCellHeight, requestHeight: requestHeight)
                            return height
                        }
                    } else {
                        return contactHeight(contactCellHeight, requestHeight: requestHeight)
                    }
                } else {
                    return contactHeight(contactCellHeight, requestHeight: requestHeight)
                }
                
            } else {
                return 72
            }
        }
    }
    
    func contactHeight(_ contactCellHeight:CGFloat, requestHeight:CGFloat) -> CGFloat {
        if contactCellHeight + requestHeight < view.frame.size.height {
            let height = view.frame.size.height - requestHeight
            return height
        } else {
            return contactCellHeight
        }
        
        
    }


//  TODO: create sections ??
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        if segmentedControl.selectedSegmentIndex == 1 {
//            if let myRequests = myRequests, let myFriends = myFriends {
//                if myRequests.count > 0 && myFriends.count > 0 {
//                    return 2
//                } else {
//                    return 1
//                }
//            } else {
//                return 1
//            }
//        } else {
//            return 1
//        }
//    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        guard let myRequests = myRequests , let myFriends = myFriends else {
//            return nil
//        }
//        if segmentedControl.selectedSegmentIndex == 1 {
//            if myRequests.count > 0 && myFriends.count > 0 {
//                if section == 1 {
//                    return "Friend Requests"
//                } else {
//                    return "Friends"
//                }
//            } else {
//               return nil
//            }
//        } else {
//            return nil
//        }
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let convoCell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! HomeMessageCell
            if let myConversations = myConversations {
                if myConversations.count != 0 {
                    let convo = myConversations[(indexPath as NSIndexPath).row]
                    convoCell.messageText.text = convo.lastMessage?.messageText
                    var groupName = convo.convoName
                    if let myName = UserController.sharedInstance.myRelationship?.fullName {
                        if groupName?.contains(myName) == true {
                            if let range = groupName?.range(of: "\(myName), ") {
                                groupName?.removeSubrange(range)
                                convoCell.userName.text = groupName
                            }
                            if let range = groupName?.range(of: ", \(myName)") {
                                groupName?.removeSubrange(range)
                                convoCell.userName.text = groupName
                            }
                        } else if groupName != nil {
                            convoCell.userName.text = groupName
                        } else {
                            convoCell.userName.text = "..."
                        }
                    }
                    if let time = convo.lastMessage?.timeString {
                        convoCell.messageTime.text = time
                    }
                    if let userPic = convo.lastMessage?.userPic {
                        convoCell.userImage.image = userPic
                    }
                    if UserController.sharedInstance.myRelationship!.alerts.count != 0 {
                        if let convoRecord = convoRecords?[indexPath.row] {
                            let convoRef = CKReference(record: convoRecord, action: .deleteSelf)
                            for a in UserController.sharedInstance.myRelationship!.alerts {
                                if convoRef != a {
                                    convoCell.alertImage.isHidden = true
                                } else {
                                    convoCell.userNameLeadingConstraint.constant = convoCell.userNameLeadingConstraint.constant + 15
                                }
                            }
                        }
                        
                    } else {
                        convoCell.alertImage.isHidden = true
                    }
                }
            } else if skippedLogin {
                convoCell.messageText.text = "Create an account to get started socializing."
                convoCell.alertImage.isHidden = true
            } else {
                convoCell.alertImage.isHidden = true
            }
            return convoCell
            
        } else {
            if (indexPath as NSIndexPath).row == numberInSection {
                let contactCell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell
                return contactCell
                
            } else {
                let notificationCell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
                
                if let myRequests = myRequests {
                    if myRequests.count != 0 {
                        let index = (indexPath as NSIndexPath).row
                        let name = myRequests[index].fullName
                        notificationCell.inviteLabel.text = name
                        if let asset = myRequests[index].profilePic {
                            notificationCell.profilePic.image = asset.image
                        }
                    }
                }
                return notificationCell
            }
        }
    }
    
    func returnLastMessage(_ conversation: Conversation, profilePic: CKAsset?) {
        changedConvo = conversation
        convoImage = profilePic
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if let myConversations = myConversations {
                if myConversations.count != 0 {
                    return myConversations.count
                } else {
                    return 0
                }
            } else if demo {
                return 1
            } else if skippedLogin {
                return 1
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
                self.tableView.isScrollEnabled = false
                self.numberInSection = 0
                return 1
            }
        }
    }
    
//    var requestIndex:Int?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: "messageSegue", sender: self)
        } else {
            if indexPath.row < numberInSection! {
                contactView.center = CGPoint(x: view.frame.width + 100, y: view.bounds.height / 2)
                darkView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
                darkView.backgroundColor = UIColor.black
                darkView.alpha = 0.5
                
//        set up contactView content
                if let myRequests = myRequests {
                    if myRequests.count != 0 {
                        bigName.text = myRequests[(indexPath as NSIndexPath).row].fullName
                        contactRelationship = myRequests[(indexPath as NSIndexPath).row]
                        
                        if let asset = myRequests[(indexPath as NSIndexPath).row].profilePic {
                            bigProfilePic.image = asset.image
                        } else {
                            bigProfilePic.image = UIImage(named: "Square Contact")
                        }
                        
                        addToGroupContactViewButton.tag = (indexPath as NSIndexPath).row
                        removeFriendContactViewButton.tag = (indexPath as NSIndexPath).row
                        addToGroupContactViewXConstraint.constant = addToGroupContactViewXConstraint.constant + 30
                        removeFriendContactViewXConstraint.constant = removeFriendContactViewXConstraint.constant - 30
                        messageContactViewButton.isEnabled = false
                        messageContactViewButton.isHidden = true
                    }
                }
                
                self.view.addSubview(self.darkView)
                self.view.addSubview(self.contactView)
                self.removeFriendContactViewButton.imageView?.image = UIImage(named: "Red Cancel")
                self.addToGroupContactViewButton.imageView?.image = UIImage(named: "Blue Checked")
                
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.contactView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                    }, completion: nil)
            }
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageSegue" {
            if let myConversations = myConversations {
                if myConversations.count != 0 {
                    let destinationVC = segue.destination as! MessagingViewController
                    if let convoIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                        destinationVC.convoRecord = convoRecords![convoIndex]
                        let myConversation = myConversations[convoIndex]
                        
                        // Alerts work
                        if let alerts = UserController.sharedInstance.myRelationship?.alerts {
                            var alertInt = -1
                            for alert in alerts {
                                alertInt = alertInt + 1
                                if convoRecords![convoIndex].recordID == alert.recordID {
                                    
                                    UserController.sharedInstance.myRelationship?.alerts.remove(at: alertInt)
                                    // Fix constraint that was moved for alertview
                                    let cell = tableView.cellForRow(at: IndexPath(row: convoIndex, section: 0)) as! HomeMessageCell
                                    cell.userNameLeadingConstraint.constant = cell.userNameLeadingConstraint.constant - 15
                                    
                                    UserController.sharedInstance.saveRecordArray((UserController.sharedInstance.myRelationship?.alerts)!, record: UserController.sharedInstance.myRelationshipRecord!, string: "Alerts", completion: { (success) in
                                        if success == false {
                                            print("had issues removing alerts")
                                        }
                                    })
                                }
                            }
                        }
                        
                        // Grab Messages
                        ConversationController.sharedInstance.grabMessages(myConversation, completion: { (error, conversation, theMessages) in
                            if let error = error {
                                destinationVC.conversation = conversation
                                destinationVC.conversation?.messages = []
                                destinationVC.conversation?.theMessages = []
                                destinationVC.sendButton.isEnabled = true
                                destinationVC.setMessageNavBar(conversationName: (conversation?.convoName)!)
                                print("ERROR: \(error)")
                            } else {
                                if let messages = conversation!.messages,
                                    let theMessages = theMessages {
                                    var passOnConversation = Conversation(convoName: conversation?.convoName, users: (conversation?.users)!, messages: messages)
                                    passOnConversation.theMessages = theMessages
                                    destinationVC.conversation?.theMessages = theMessages
                                    destinationVC.conversation?.messages = messages
                                    destinationVC.conversation = passOnConversation
                                    DispatchQueue.main.async(execute: {
                                        destinationVC.tableView.reloadData(destinationVC.conversation)
                                        destinationVC.sendButton.isEnabled = true
                                        
                                        destinationVC.setMessageNavBar(conversationName: (conversation?.convoName)!)
                                    })
                                }
                            }
                        })
                    } else {
                        print("ERROR")
                    }
                } else {
                    let destinationVC = segue.destination as! MessagingViewController
                    destinationVC.demo = demo
                    destinationVC.skippedLogin = skippedLogin
                }
            } else {
                if demo {
                    let destinationVC = segue.destination as! MessagingViewController
                    destinationVC.demo = demo
                } else if skippedLogin {
                    let destinationVC = segue.destination as! MessagingViewController
                    destinationVC.skippedLogin = skippedLogin
                } else {
                    let destinationVC = segue.destination as! MessagingViewController
                    destinationVC.tableView.reloadData()
                }
            }
        } else if segue.identifier == "newMessageSegue" {
            let destinationVC = segue.destination as! MessagingViewController
            destinationVC.conversation = self.passOnConvo
            destinationVC.newConvo = true
            destinationVC.convoRecord = self.convoRecord
            setMessageNavBar(conversationName: (passOnConvo?.convoName)!)
            
        } else if segue.identifier == "addToGroup" {
            let navController = segue.destination as! UINavigationController
            let destinationVC = navController.topViewController as! CreateGroupViewController
            destinationVC.contacts = self.myFriends
            destinationVC.initialContact = self.contactRelationship
        }
    }
    
    
// MARK: Friend Request actions
    
    func acceptButtonTapped(_ sender: AnyObject) {
        if myRequests != nil {
            requests = []
            let requester = myRequests?[sender.tag]
            myRequests!.remove(at: sender.tag)
            guard let myRequests = myRequests else {
                return
            }
            for request in myRequests {
                requests? += [request.userID]
            }
            UserController.sharedInstance.saveRecordArray(self.requests!, record: UserController.sharedInstance.myRelationshipRecord!, string: "FriendRequests") { (success) in
                if success {
                    if UserController.sharedInstance.myRelationship?.friends != nil {
                        var friends = UserController.sharedInstance.myRelationship?.friends
                        let ref = CKReference(recordID: requester!.userID.recordID, action: .deleteSelf)
                        friends? += [ref]
                        UserController.sharedInstance.saveRecordArray(friends!, record: UserController.sharedInstance.myRelationshipRecord!, string: "Friends", completion: { (success) in
                            if success {
                                UserController.sharedInstance.acceptRequest(UserController.sharedInstance.currentUser!, friend: requester!, completion: { (success, record) in
                                    if success {
                                        let relationship = Relationship(fullName: record!["FullName"] as! String, userID: record!["UserIDRef"] as! CKReference, requests: nil, friends: nil, profilePic: record!["ImageKey"] as? CKAsset)
                                        DispatchQueue.main.async(execute: {
                                            self.myFriends! += [relationship]
                                            self.tableView.reloadData()
                                            let indexPath = IndexPath(row: self.numberInSection!, section: 0)
                                            let cell = self.tableView.cellForRow(at: indexPath) as! ContactTableViewCell
                                            cell.collectionView.reloadData()
                                        })
                                    } else {
                                        DispatchQueue.main.async(execute: { 
                                            let alert = UIAlertController(title: "Error", message: "Couldn't save friends friends", preferredStyle: .alert)
                                            let action = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                                                return
                                            })
                                            alert.addAction(action)
                                            self.present(alert, animated: true, completion: nil)
                                        })
                                    }
                                })
                            } else {
                                DispatchQueue.main.async(execute: {
                                    let alert = UIAlertController(title: "Error", message: "Couldn't save friends friends", preferredStyle: .alert)
                                    let action = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                                        return
                                    })
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    } else {
                        var friends = UserController.sharedInstance.myRelationship?.friends
                        let ref = CKReference(recordID: requester!.userID.recordID, action: .deleteSelf)
                        friends? += [ref]
                        UserController.sharedInstance.saveRecordArray(friends!, record: UserController.sharedInstance.myRelationshipRecord!, string: "Friends", completion: { (success) in
                            if success {
                                UserController.sharedInstance.acceptRequest(UserController.sharedInstance.currentUser!, friend: requester!, completion: { (success, record) in
                                    if success {
                                        let relationship = Relationship(fullName: record!["FullName"] as! String, userID: record!["UserIDRef"] as! CKReference, requests: nil, friends: nil, profilePic: record!["ImageKey"] as? CKAsset)
                                        DispatchQueue.main.async(execute: {
                                            self.myFriends! += [relationship]
                                            self.tableView.reloadData()
                                            let indexPath = IndexPath(row: self.numberInSection!, section: 0)
                                            let cell = self.tableView.cellForRow(at: indexPath) as! ContactTableViewCell
                                            cell.collectionView.reloadData()
                                        })
                                    } else {
                                        DispatchQueue.main.async(execute: {
                                            let alert = UIAlertController(title: "There was an issue accepting your friend requests.", message: nil, preferredStyle: .alert)
                                            let action = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                                                return
                                            })
                                            alert.addAction(action)
                                            self.present(alert, animated: true, completion: nil)
                                        })
                                    }
                                })
                            } else {
                                DispatchQueue.main.async(execute: {
                                    let alert = UIAlertController(title: "There was an issue accepting your friend requests.", message: nil, preferredStyle: .alert)
                                    let action = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                                        return
                                    })
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                        })
                    }
                } else {
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "There was an issue accepting your friend requests.", message: nil, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                            return
                        })
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            }
        }
    }

    func declineButtonTapped(_ sender: AnyObject) {
        myRequests?.remove(at: sender.tag)
        for request in self.myRequests! {
            let ref = CKReference(recordID: request.userID.recordID, action: .deleteSelf)
            requests? += [ref]
        }
        if let requesters = requests {
            UserController.sharedInstance.saveRecordArray(requesters, record: UserController.sharedInstance.myRelationshipRecord!, string: "FriendRequests") { (success) in
                if success {
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                } else {
                    NSLog("Didn't save friend requests")
                }
            }
        } else {
            UserController.sharedInstance.saveRecordArray([], record: UserController.sharedInstance.myRelationshipRecord!, string: "FriendRequests") { (success) in
                if success {
                    DispatchQueue.main.async(execute: {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "contactItem", for: indexPath) as! ContactCollectionCell
        if let myFriends = myFriends {
            if myFriends.count != 0 {
                let index = (indexPath as NSIndexPath).item
                item.contactName.text = myFriends[index].fullName
                if let asset = myFriends[index].profilePic {
                    item.contactImage.image = asset.image
                } else {
                    item.contactImage.image = UIImage.init(named: "Square Contact")
                }
            }
        }
//        item.layer.borderWidth = 0.4
//        item.layer.borderColor = UIColor.init(red: 0, green: 98/250, blue: 155/250, alpha: 1.0).CGColor
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let myFriends = myFriends {
            if myFriends.count != 0 {
                return myFriends.count
            } else if demo {
                return 1
            } else {
                return 0
            }
        } else if demo {
            return 1
        } else if skippedLogin {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width:(self.view.bounds.width / 3) - 12, height:150)
        return size
    }

    var index:Int?
    @IBOutlet var bigProfilePic: UIImageView!
    @IBOutlet var bigName: UILabel!
    @IBOutlet var dismissButton: UIButton!

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = (indexPath as NSIndexPath).item
        
//        get cell for contact collection view to start animation from item center
        guard case segmentedControl.selectedSegmentIndex = 1 else {
            return
        }
        let cellIndex = IndexPath(row: numberInSection!, section: 0)
        let cell = tableView.cellForRow(at: cellIndex) as! ContactTableViewCell
//        start view at item
        if let item = cell.collectionView.layoutAttributesForItem(at: indexPath) {
            contactView.center.x = item.center.x
            contactView.center.y = item.frame.maxY
        } else {
            contactView.center = CGPoint(x: view.frame.width + 100, y: view.bounds.height / 2)
        }
        
        darkView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        darkView.backgroundColor = UIColor.black
        darkView.alpha = 0.5
        
//        set up contactView content
        if let myFriends = myFriends {
            if myFriends.count != 0 {
                bigName.text = myFriends[(indexPath as NSIndexPath).item].fullName
                contactRelationship = myFriends[(indexPath as NSIndexPath).item]
                
                if let asset = myFriends[(indexPath as NSIndexPath).item].profilePic {
                    bigProfilePic.image = asset.image
                } else {
                    bigProfilePic.image = UIImage(named: "Square Contact")
                }
            }
        }
        view.addSubview(darkView)
        messageContactViewButton.isHidden = false
        messageContactViewButton.isEnabled = true
        view.addSubview(contactView)
    
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.contactView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            }, completion: nil)
    }
    
// MARK: Contact View
    
    @IBAction func contactDismissButtonTapped(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            guard case self.segmentedControl.selectedSegmentIndex = 1 else {
                return
            }
            // Contact
            if self.index != nil {
                let cellIndex = IndexPath(row: self.numberInSection!, section: 0)
                let cell = self.tableView.cellForRow(at: cellIndex) as! ContactTableViewCell
                let indexPath = IndexPath(item: self.index!, section: 0)
                
                if let item = cell.collectionView.layoutAttributesForItem(at: indexPath) {
                    self.contactView.center.x = item.center.x
                    self.contactView.center.y = item.frame.maxY
                } else {
                    self.contactView.center = CGPoint(x: -100, y: self.view.bounds.height / 2)
                }
                self.index = nil
            // Request
            } else {
                self.contactView.center = CGPoint(x: -100, y: self.view.bounds.height / 2)
                self.addToGroupContactViewButton.imageView?.image = UIImage(named: "Add User Group Man Man-50-2")
                self.addToGroupContactViewXConstraint.constant = self.addToGroupContactViewXConstraint.constant - 30
                self.removeFriendContactViewButton.imageView?.image = UIImage(named: "Remove User Male-50-2")
                self.removeFriendContactViewXConstraint.constant = self.removeFriendContactViewXConstraint.constant + 30
            }
            
        }) { (true) in
            self.contactView.removeFromSuperview()
            self.darkView.removeFromSuperview()
        }
        
    }
    
    @IBAction func addToGroupButtonPressed(_ sender: AnyObject) {
        guard let myFriends = myFriends else {
            return
        }
        // Contact
        if index != nil {
            if myFriends.count != 0 {
                DispatchQueue.main.async {
                    self.contactView.removeFromSuperview()
                    self.darkView.removeFromSuperview()
                    self.performSegue(withIdentifier: "addToGroup", sender: self)
                    
                    let destinationVC = CreateGroupViewController()
                    destinationVC.contacts = self.myFriends
                    destinationVC.initialContact = self.contactRelationship
                }
            }
        // Request
        } else {
            acceptButtonTapped(addToGroupContactViewButton)
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.contactView.center = CGPoint(x: -100, y: self.view.bounds.height / 2)
                self.removeFriendContactViewXConstraint.constant = self.removeFriendContactViewXConstraint.constant + 30
                self.addToGroupContactViewXConstraint.constant = self.addToGroupContactViewXConstraint.constant - 30
                }, completion: { (true) in
                    self.contactView.removeFromSuperview()
                    self.darkView.removeFromSuperview()
            })
        }
    }
    
    @IBAction func removeFriendButtonPressed(_ sender: AnyObject) {
        guard let myFriends = myFriends else {
            return
        }
        // Contact
        if index != nil {
            if myFriends.count != 0 {
                self.myFriends?.remove(at: index!)
                UserController.sharedInstance.myRelationship?.friends? = []
                if self.myFriends!.count > 0 {
                    for friend in self.myFriends! {
                        let ref = CKReference(recordID: friend.userID.recordID, action: .deleteSelf)
                        UserController.sharedInstance.myRelationship?.friends? += [ref]
                    }
                }
                
                if self.myFriends?.count != 0 {
                    DispatchQueue.main.async(execute: {
                        self.contactView.removeFromSuperview()
                        self.darkView.removeFromSuperview()
                        let indexPath = IndexPath(row: self.numberInSection!, section: 0)
                        let cell = self.tableView.cellForRow(at: indexPath) as! ContactTableViewCell
                        cell.collectionView.reloadData()
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.contactView.removeFromSuperview()
                        self.darkView.removeFromSuperview()
                        let indexPath = IndexPath(row: self.numberInSection!, section: 0)
                        let cell = self.tableView.cellForRow(at: indexPath) as! ContactTableViewCell
                        cell.collectionView.reloadData()
                    })
                }
                UserController.sharedInstance.saveRecordArray((UserController.sharedInstance.myRelationship?.friends)!, record: UserController.sharedInstance.myRelationshipRecord!, string: "Friends") { (success) in
                    if success {
                        UserController.sharedInstance.removeFriend(self.contactRelationship!, currentRel: UserController.sharedInstance.myRelationship!, completion: { (success) in
                            if success == false {
                                let alertController = UIAlertController(title: "Uh oh", message: "There was an error removing your friend.", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                                alertController.addAction(action)
                                DispatchQueue.main.async(execute: {
                                    self.present(alertController, animated: true, completion: nil)
                                })
                            }
                        })
                        
                    } else {
                        let alertController = UIAlertController(title: "Uh oh", message: "There was an error removing your friend.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                        alertController.addAction(action)
                        DispatchQueue.main.async(execute: {
                            self.present(alertController, animated: true, completion: nil)
                        })
                    }
                }
            }
            let indexPath = IndexPath(row: self.numberInSection!, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! ContactTableViewCell
            cell.collectionView.reloadData()
            
        // Request
        } else {
            declineButtonTapped(removeFriendContactViewButton)
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.contactView.center = CGPoint(x: -100, y: self.view.bounds.height / 2)
                    self.removeFriendContactViewXConstraint.constant = self.removeFriendContactViewXConstraint.constant + 30
                    self.addToGroupContactViewXConstraint.constant = self.addToGroupContactViewXConstraint.constant - 30
                }, completion: { (true) in
                    self.contactView.removeFromSuperview()
                    self.darkView.removeFromSuperview()
            })
        }
    }
    
    @IBAction func sendMessageButtonTapped(_ sender: AnyObject) {
        if let myFriends = myFriends {
            if myFriends.count != 0 {
                let myRelationship = UserController.sharedInstance.myRelationship
                let conversation = Conversation.init(convoName: "\((myRelationship?.fullName)!), \((contactRelationship?.fullName)!)", users: [myRelationship!.userID, contactRelationship!.userID], messages: [])
                ConversationController.createConversation(conversation) { (success, record) in
                    if success {
                        self.convoRecord = record
                        self.passOnConvo = conversation
                        
                        // Send Alert
                        var groupName = conversation.convoName
                        if let myName = UserController.sharedInstance.myRelationship?.fullName {
                            if groupName?.contains(myName) == true {
                                if let range = groupName?.range(of: "\(myName), ") {
                                    groupName?.removeSubrange(range)
                                }
                                if let range = groupName?.range(of: ", \(myName)") {
                                    groupName?.removeSubrange(range)
                                }
                            }
                        }
                        let convoRef = CKReference(record: record!, action: .deleteSelf)
                        UserController.sharedInstance.sendAlert(convoRef: convoRef, convoName: groupName!)
                        
                        DispatchQueue.main.async(execute: {
                            self.contactView.removeFromSuperview()
                            self.darkView.removeFromSuperview()
                            self.performSegue(withIdentifier: "newMessageSegue", sender: self)
                        })
                        
                    } else {
                        print("Not this time")
                    }
                }
                
            } else {
                DispatchQueue.main.async(execute: {
                    self.contactView.removeFromSuperview()
                    self.darkView.removeFromSuperview()
                    self.performSegue(withIdentifier: "newMessageSegue", sender: self)
                })
            }
        } else if bigName.text == "Socialize"  {
            let alert = UIAlertController(title: "Get some friends", message: "Add contacts to start socializing", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
}

extension UIViewController {
    
    func setNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 0, green: 0.384, blue: 0.608, alpha: 1.0)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        let iconImage = UIImage.init(named: "Little White Icon")
        let imageView = UIImageView(frame: CGRect(x: 0, y: -5, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        imageView.image = iconImage
        navigationItem.titleView = imageView
    }
    
    func setMessageNavBar(conversationName: String) {
        var groupName = conversationName
        navigationItem.titleView = nil
        
        let myName = UserController.sharedInstance.myRelationship?.fullName
        if conversationName.contains(myName!) {
            if let range = conversationName.range(of: "\(myName!), ") {
                groupName.removeSubrange(range)
                navigationItem.title = groupName
            }
            if let range = conversationName.range(of: ", \(myName!)") {
                groupName.removeSubrange(range)
                navigationItem.title = groupName
            }
        } else {
            navigationItem.title = groupName
        }
    }
    
}


