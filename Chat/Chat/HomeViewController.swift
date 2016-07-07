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

    
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    let darkView = UIView()
    var requests: [CKReference]?
    var myRequests: [Relationship]?
    var numberInSection:Int?
//    var friends: [CKReference]?
    var myFriends: [Relationship]?
    var contactRelationship: Relationship?
    var addContactIndex:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        tableView.reloadData()
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
 
// MARK: Segmented Control
    
    @IBAction func segmentedControlChanged(sender: AnyObject) {
        tableView.reloadData()
        if segmentedControl.selectedSegmentIndex == 1 {
            tableView.separatorColor = UIColor.clearColor()
        }
    }

    
// MARK: TableView
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == 0 {
            return 100
            
        } else {
            if indexPath.row == 0 {
                return 55
                
            } else if indexPath.row == numberInSection {
                
//                TODO:
                if myFriends?.count == 1 {
                    let contactCellHeight = CGFloat(120 * myFriends!.count) + 10
                    return contactCellHeight
                } else if (myFriends?.count)! % 2 == 1 {
                    let contactCellHeight = CGFloat(120 * ((myFriends!.count + 1)/2)) + 30
                    return contactCellHeight
                } else {
                    let contactCelHeight = CGFloat(120 * (myFriends!.count/2)) + 30
                    return contactCelHeight
                }
        
            } else {
                return 95
            }
        }
    }
    
    
//  TODO: create sections ??

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let convoCell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as! HomeMessageCell
            return convoCell
            
        } else {
            
            if indexPath.row == 0 {
                let addContactCell = tableView.dequeueReusableCellWithIdentifier("addContact", forIndexPath: indexPath)
                return addContactCell
            
            } else if indexPath.row == numberInSection {
                let contactCell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactTableViewCell
                return contactCell
                
            } else {
                let notificationCell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! NotificationCell
                notificationCell.acceptButton.tag = indexPath.row - 1
                notificationCell.declineButton.tag = indexPath.row - 1
                if let myRequests = myRequests {
                    if myRequests.count != 0 {
                        let index = indexPath.row - 1
                        let name = myRequests[index].fullName
                        notificationCell.inviteLabel.text = "\(name) sent you a friend request"
//                        TODO: Image
                    } else {
                        
                    }
                } else {
                    
                }
                return notificationCell
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            return 2
        } else {
            if let requests = self.myRequests {
                if requests.count == 0 {
                    self.numberInSection = 1
                    return 2
                    
                } else {
                    let number = requests.count + 2
                    self.numberInSection = number - 1
                    return number
                }
            } else {
                self.numberInSection = 1
                return 2
            }
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            performSegueWithIdentifier("messageSegue", sender: self)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
// MARK: Friend Request actions
    
    @IBAction func acceptButtonTapped(sender: AnyObject) {
        let requester = myRequests?[sender.tag]
        self.myRequests!.removeAtIndex(sender.tag)
        for request in myRequests! {
            let ref = CKReference(recordID: request.userID.recordID, action: .DeleteSelf)
            self.requests! += [ref]
        }
        if self.requests == nil {
            self.requests = []
        }
        UserController.sharedInstance.saveRecordArray(self.requests!, record: UserController.sharedInstance.myRelationshipRecord!, string: "FriendRequests") { (success) in
            if success {
                if UserController.sharedInstance.myRelationship?.friends != nil {
                    var friends = UserController.sharedInstance.myRelationship?.friends
                    let ref = CKReference(recordID: requester!.userID.recordID, action: .DeleteSelf)
                    friends? += [ref]
                    UserController.sharedInstance.saveRecordArray(friends!, record: UserController.sharedInstance.myRelationshipRecord!, string: "Friends", completion: { (success) in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        } else {
                            
                        }
                    })
                } else {
                    var friends: [CKReference]
                    let ref = CKReference(recordID: requester!.userID.recordID, action: .DeleteSelf)
                    friends = [ref]
                    UserController.sharedInstance.saveRecordArray(friends, record: UserController.sharedInstance.myRelationshipRecord!, string: "Friends", completion: { (success) in
                        if success {
                            dispatch_async(dispatch_get_main_queue(), { 
                                self.tableView.reloadData()
                            })
                        } else {
                            
                        }
                    })
                    
                }
            } else {
                
            }
        }
        
    }
 
    @IBAction func declineButtonTapped(sender: AnyObject) {
        self.requests?.removeAtIndex(sender.tag)
        UserController.sharedInstance.saveRecordArray(requests!, record: UserController.sharedInstance.myRelationshipRecord!, string: "FriendRequests") { (success) in
            if success {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    
    
// MARK: Collection View
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCellWithReuseIdentifier("contactItem", forIndexPath: indexPath) as! ContactCollectionCell
        let index = indexPath.item
        item.contactName.text = myFriends![index].fullName
//        TODO: Image
        return item
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myFriends!.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width:(self.view.bounds.width / 2) - 10, height:125)
        return size
    }
    
//    
//    
//    
//    
//    TODO:
    @IBOutlet var bigProfilePic: UIImageView!
    @IBOutlet var bigName: UILabel!

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        contactView.center.x = view.center.x
        contactView.center.y = view.center.y - 40
        self.bigName.text = myFriends![indexPath.item].fullName
        contactRelationship = myFriends![indexPath.item]
//        TODO: Image
        darkView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        darkView.backgroundColor = UIColor.blackColor()
        darkView.alpha = 0.5
        
        self.view.addSubview(darkView)
        self.view.addSubview(contactView)
        
    }
    
// MARK: Contact View
    
    @IBAction func contactDismissButtonTapped(sender: AnyObject) {
        contactView.removeFromSuperview()
        darkView.removeFromSuperview()
    }
    
    @IBAction func addToGroupButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("addToGroup", sender: self)
    }
    
    @IBAction func sendMessageButtonTapped(sender: AnyObject) {
        let myRelationship = UserController.sharedInstance.myRelationship
        let conversation = Conversation.init(convoName: contactRelationship!.fullName, users: [myRelationship!.userID, contactRelationship!.userID])
        ConversationController.createConversation(conversation) { (success) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.contactView.removeFromSuperview()
                    self.darkView.removeFromSuperview()
                    self.performSegueWithIdentifier("messageSegue", sender: self)
                })
                print("Convo: \(conversation.users)")
            } else {
                print("Not this time")
            }
            
        }
    }
   
//    TODO: Pass on what you need
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addToGroup" {
            
        }
    }

}

extension UIViewController {
    
    func setNavBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0, green: 0.384, blue: 0.608, alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let iconImage = UIImage.init(named: "Little White Icon")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = iconImage
        self.navigationItem.titleView = imageView
    }
    
    func setInitialNavBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0, green: 0.384, blue: 0.608, alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

}


