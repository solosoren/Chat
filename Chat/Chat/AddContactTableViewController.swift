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
    var appeared = false
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavBar()
        navigationItem.backBarButtonItem?.image = UIImage(named: "Down")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchResultsCell = tableView.dequeueReusableCell(withIdentifier: "searchResultsCell", for: indexPath) as! UserSearchTableViewCell
        searchResultsCell.relationship = searchedUsers[indexPath.row]
        searchResultsCell.usernameLabel.text = searchResultsCell.relationship!.fullName
        
        searchResultsCell.sendRequestButton.tag = indexPath.row
//        see if this works
        
        DispatchQueue.main.async {
            UserController.sharedInstance.grabImage(searchResultsCell.relationship!.fullName) { (success, image) in
                if success == true {
                    DispatchQueue.main.async {
                        searchResultsCell.profilePic.image = image
                    }
                } else {
                    searchResultsCell.profilePic.image = nil
                }
            }
        }

        return searchResultsCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 52
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bigContactView.center.x = view.center.x
        bigContactView.center.y = view.center.y - 40
        let user = searchedUsers[indexPath.row]
        bigContactView.relationship = user
        let cell = tableView.cellForRow(at: indexPath) as! UserSearchTableViewCell
        DispatchQueue.main.async {
            if user.profilePic != nil {
                self.bigContactView.profilePic.image = cell.profilePic.image
                self.bigContactView.profilePic.backgroundColor = UIColor.clear
            }
            
        }
        
        darkView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        darkView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height + 200)
        
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
            self.statusBarIsVisible = false
            self.setNeedsStatusBarAppearanceUpdate()

            switch self.appeared {
            case true:
                self.darkView.isHidden = false
            default:
                self.view.addSubview(self.darkView)
            }
            self.view.addSubview(self.bigContactView)
            self.searchBar.resignFirstResponder()
            tableView.isScrollEnabled = false
        }
        panRec.addTarget(self, action: #selector(AddContactTableViewController.swipedView))
        bigContactView.addGestureRecognizer(panRec)
        bigContactView.isUserInteractionEnabled = true

        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override var prefersStatusBarHidden : Bool {
        if statusBarIsVisible {
            return false
        } else {
            return true
        }
    }
    
    func swipedView(_ sender:UIPanGestureRecognizer) {
        var start = CGPoint(x:0, y:0)
        var end = CGPoint(x:0, y:0)
        
        if sender.state == .began {
            start = sender.location(in: bigContactView)
        } else if sender.state == .ended {
            end = sender.location(in: bigContactView)
            let dx = end.x - start.x
            let dy = end.y - start.y
            let distance = sqrt(dx*dx + dy*dy)
            let max = CGFloat(205)
            if distance > max {
                UIView.animate(withDuration: 0.2, delay:0.0, options: .curveEaseIn, animations: {
                    self.bigContactView.center = CGPoint(x: self.view.center.x, y: self.view.frame.size.height + 200)
                    }, completion: { (finished) in
                        if finished {
                            DispatchQueue.main.async(execute: { 
                                self.appeared = true
                                self.darkView.isHidden = true
                                self.navigationController?.isNavigationBarHidden = false
                                self.statusBarIsVisible = true
                                self.setNeedsStatusBarAppearanceUpdate()
                                self.tableView.isScrollEnabled = true
                            })
                        }
                })
            } else {
                return
            }
        }
    }
    
    func getIndexOfUserWithUserId(_ user: User, userArray: [User]) -> Int {
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
    
    @IBAction func addContactButtonTapped(_ sender: AnyObject) {
        let user = UserController.sharedInstance.currentUser
        let relationshipID = UserController.sharedInstance.myRelationship?.userID.recordID
        let friend = searchedUsers[sender.tag]
        if relationshipID != friend.userID.recordID {
            if let user = user {
                UserController.sharedInstance.sendRequest(user, friend: friend) { (success, record, alreadyFriends, alreadyRequested) in
                    if success {
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertController(title: "A friend request has been sent to \(friend.fullName)", message: nil, preferredStyle: .alert)
                            let action = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                                self.performSegue(withIdentifier: "addedContact", sender: self)
                                
                            })
                            alert.addAction(action)
                            self.present(alert, animated: true, completion:nil)
                        })
                    } else if alreadyRequested == true {
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertController(title: "You've already sent a friend request to \(friend.fullName).", message: nil, preferredStyle: .alert)
                            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                            alert.addAction(okay)
                            self.present(alert, animated: true, completion: nil)
                        })
                    } else if alreadyFriends == true {
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertController(title: "\(friend.fullName) is already your friend.", message: nil, preferredStyle: .alert)
                            let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                            alert.addAction(okay)
                            self.present(alert, animated: true, completion: nil)
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertController(title: "Their was an error sending the friend request.", message: nil, preferredStyle: .alert)
                            let retry = UIAlertAction(title: "Retry", style: .default, handler: nil)
                            //                TODO: Fix
                            alert.addAction(retry)
                            self.present(alert, animated: true, completion: nil)
                        })
                    }
                }
            }
        } else {
            print("error")
        }
    }
    
}

extension AddContactTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.async {
            UserController.sharedInstance.searchAllUsers(searchText) { (success, users) in
                if success {
                    if let users = users {
                        self.searchedUsers = users
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                } else {
                    print("Not working")
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            DispatchQueue.main.async {
                UserController.sharedInstance.searchAllUsers(searchBar.text!, completion: { (success, users) in
                    if success {
                        if let users = users {
                            self.searchedUsers = users
                            DispatchQueue.main.async(execute: {
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






