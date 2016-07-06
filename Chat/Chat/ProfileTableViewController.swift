//
//  ProfileViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var displayName: UITextField!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    func setUpView() {
        dispatch_async(dispatch_get_main_queue()) { 
            if let fullName = UserController.sharedInstance.currentUser?.fullName {
                self.displayName.text = fullName
            }
            UserController.sharedInstance.grabImage(UserController.sharedInstance.currentUser!) { (success, image) in
                if success {
                    self.profilePic.image = image
                }
            }

        }
        self.setNavBar()
    }
    
    
}
