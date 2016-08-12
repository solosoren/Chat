//
//  AddContactTableViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

class AddContactTableViewController: UITableViewController {
    
//    get another picture to switch to when sent instead of alert
//    cant search for people who are alread friends
    
    
    @IBOutlet var cellButton: UIButton!
    @IBOutlet var bigContactView: BigContactView!
    let panRec = UIPanGestureRecognizer()
    var statusBarIsVisible = true


    var searchedUsers: [Relationship] = []
    let darkView = UIView()
    var names: [String] = []
    var requests: [CKReference]?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let searchResultsCell = tableView.dequeueReusableCellWithIdentifier("searchResultsCell", forIndexPath: indexPath) as! UserSearchTableViewCell
        searchResultsCell.relationship = searchedUsers[indexPath.row]
        searchResultsCell.usernameLabel.text = searchResultsCell.relationship!.fullName
        
        searchResultsCell.sendRequestButton.tag = indexPath.row
//        see if this works
        
        dispatch_async(dispatch_get_main_queue()) {
            UserController.sharedInstance.grabImage(searchResultsCell.relationship!.fullName) { (success, image) in
                if success == true {
                    dispatch_async(dispatch_get_main_queue()) {
                        searchResultsCell.profilePic.image = image
                    }
                } else {
                    searchResultsCell.profilePic.image = nil
                }
            }
        }

        return searchResultsCell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 52
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        bigContactView.center.x = view.center.x
        bigContactView.center.y = view.center.y - 40
        let user = searchedUsers[indexPath.row]
        bigContactView.relationship = user
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserSearchTableViewCell
        dispatch_async(dispatch_get_main_queue()) {
            self.bigContactView.profilePic.image = cell.profilePic.image
        }
        
        darkView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        darkView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height + 200)
        
        tableView.scrollEnabled = false
        
        
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController?.navigationBarHidden = true
            self.navigationController?.prefersStatusBarHidden()
            self.statusBarIsVisible = false
            self.preferredStatusBarStyle()
            self.setNeedsStatusBarAppearanceUpdate()
            self.view.addSubview(self.darkView)
            self.view.addSubview(self.bigContactView)
        }
        panRec.addTarget(self, action: #selector(AddContactTableViewController.swipedView))
        bigContactView.addGestureRecognizer(panRec)
        bigContactView.userInteractionEnabled = true

        searchBar.resignFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if statusBarIsVisible {
            return false
        } else {
            return true
        }
    }
    
    func swipedView(sender:UIPanGestureRecognizer) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.bigContactView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            self.navigationController?.navigationBarHidden = false
            self.statusBarIsVisible = true
            self.prefersStatusBarHidden()
            self.setNeedsStatusBarAppearanceUpdate()
            
            self.tableView.scrollEnabled = true
        }
    }
    
    func getIndexOfUserWithUserId(user: User, userArray: [User]) -> Int {
        var index = 0
        for member in userArray {
            if member.userID == user.userID {
                return index
            }
            // Each time the for loop runs 1 gets added to the index
            index += 1
        }
        return index
    }

    
    
    @IBAction func addContactButtonTapped(sender: AnyObject) {
        let user = UserController.sharedInstance.currentUser
        let friend = searchedUsers[sender.tag]
//        if user?.userID != friend?.userID {
            if let user = user {
                NSLog("Friend: \(friend.fullName)")
                UserController.sharedInstance.sendRequest(user, friend: friend) { (success, record) in
                    if success {
                        dispatch_async(dispatch_get_main_queue(), {
                            let name = record!["FullName"]
                            let alert = UIAlertController(title: nil, message: "A friend request has been sent to \(name!)", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "Okay", style: .Default, handler: { (action) in
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.performSegueWithIdentifier("addedContact", sender: self)
                                })
                            })
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion:nil)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            let alert = UIAlertController(title: "Uh oh", message: "Their was an error sending the friend request", preferredStyle: .Alert)
                            let retry = UIAlertAction(title: "Retry", style: .Default, handler: nil)
//                TODO: Fix
                            alert.addAction(retry)
//                let whatever = UIAlertAction(title: "", style: , handler: )
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
                }
            }
//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addedContact" {

        }
    }

}

extension AddContactTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        dispatch_async(dispatch_get_main_queue()) {
            UserController.sharedInstance.searchAllUsers(searchText) { (success, users) in
                if success {
                    if let users = users {
                        self.searchedUsers = users
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    }
                } else {
                    print("Not working")
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text != nil {
            dispatch_async(dispatch_get_main_queue()) {
                UserController.sharedInstance.searchAllUsers(searchBar.text!, completion: { (success, users) in
                    if success {
                        if let users = users {
                            self.searchedUsers = users
                            dispatch_async(dispatch_get_main_queue(), {
                                searchBar.resignFirstResponder()
                                self.tableView.reloadData()
                            })
                        }                       
                    } else {
                        print("Not working")
                    }
                })
            }
        }
    }
}






