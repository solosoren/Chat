//
//  ProfileViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var displayName: UITextField!
    
    
    override func viewDidLoad() {
        if let firstName = UserController.sharedInstance.currentUser?.firstName,
            lastName = UserController.sharedInstance.currentUser?.lastName {
            self.displayName.text = (firstName + " " + lastName)
        }
    }
    
    
}
