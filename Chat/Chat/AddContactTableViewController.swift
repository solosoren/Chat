//
//  AddContactTableViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit

class AddContactTableViewController: UITableViewController {
    
    @IBOutlet var bigContactView: UIView!
    var searchedUsers: [User] = []
    let darkView = UIView()
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBar()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let searchResultsCell = tableView.dequeueReusableCellWithIdentifier("searchResultsCell", forIndexPath: indexPath) as! UserSearchTableViewCell
        let user = searchedUsers[indexPath.row]
        searchResultsCell.usernameLabel.text = user.fullName
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
        darkView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        darkView.backgroundColor = UIColor.blackColor()
        darkView.alpha = 0.5
        
        self.view.addSubview(darkView)
        self.view.addSubview(bigContactView)
        self.searchBar.resignFirstResponder()
        
        
        
        
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
        
    }
    
    
    @IBAction func dismissButtonTapped(sender: AnyObject) {
        bigContactView.removeFromSuperview()
        darkView.removeFromSuperview()
    }
}

extension AddContactTableViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchedUsers = []
        dispatch_async(dispatch_get_main_queue()) { 
            UserController.sharedInstance.searchAllUsers(searchText) { (success, users) in
                if success {
                    self.searchedUsers = users!
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                } else {
                    print("not working")
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
}






















