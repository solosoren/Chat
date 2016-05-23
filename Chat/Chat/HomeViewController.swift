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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    let darkView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBar()
        self.homeNavBarImage()
//        self.performSegueWithIdentifier("loginSegue", sender: self)

        dispatch_async(dispatch_get_main_queue()) {
            UserController.sharedInstance.checkForUser { (success) in
                if success {

                } else {
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                }
            }
        }
    }
 
// MARK: Segmented Control
    
    @IBAction func segmentedControlChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
// MARK: TableView
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            return 100
            
        } else {
            if indexPath.row == 0 {
                return 55
                
            } else if indexPath.row == 1 {
                return 55
            
            } else {
//                (120(cell height) * # of friends) + 10 
                let contactCellHeight = (self.view.bounds.height * 4)
                return contactCellHeight
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let convoCell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as! HomeMessageCell
            return convoCell
            
        } else {
            if indexPath.row == 0 {
                let addContactCell = tableView.dequeueReusableCellWithIdentifier("addContact", forIndexPath: indexPath)
                return addContactCell
                
//        Im going to have to set all notifications for current user in an array and use that count
//               else if indexpath.row == 1...(notificationCount + 1)
            
            } else if indexPath.row == 1 {
                let notificationCell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath)
                return notificationCell
            
            } else {
                let contactCell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! ContactTableViewCell
                return contactCell
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            performSegueWithIdentifier("messageSegue", sender: self)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
 
// MARK: Collection View
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let item = collectionView.dequeueReusableCellWithReuseIdentifier("contactItem", forIndexPath: indexPath)
        return item
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width:(self.view.bounds.width / 2) - 10, height:120)
        return size
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        contactView.center.x = view.center.x
        contactView.center.y = view.center.y - 40
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
        let currentUserRef = CKReference(recordID: UserController.sharedInstance.currentUser!.userID, action: CKReferenceAction.None)
        let conversation = Conversation.init(convoName: nil, users: [currentUserRef])
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

}

extension UIViewController {
    
    func setNavBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0, green: 0.384, blue: 0.608, alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func homeNavBarImage() {
        let iconImage = UIImage.init(named: "Little White Icon")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = iconImage
        self.navigationItem.titleView = imageView

    }
    
    func navBarImage() {
        let iconImage = UIImage.init(named: "Little White Icon")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = iconImage
        self.navigationItem.titleView = imageView

    }
}


