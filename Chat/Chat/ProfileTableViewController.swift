//
//  ProfileViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit
import MessageUI

class ProfileTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setProfileNavBar()
        noAccount()
    }
    
    func setUpView() {
        dispatch_async(dispatch_get_main_queue()) {
            if let asset = UserController.sharedInstance.myRelationship?.profilePic {
                self.profilePic.image = asset.image
            }
        }
    }
    
    func setProfileNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 0, green: 0.384, blue: 0.608, alpha: 1.0)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        if let fullName = UserController.sharedInstance.currentUser?.fullName {
            navigationItem.title = fullName
        } else {
            navigationItem.title = "Socialize"
        }
    }
    
    func noAccount() {
        if UserController.sharedInstance.myRelationship == nil {
            dispatch_async(dispatch_get_main_queue(), { 
                let alert = UIAlertController(title: "No Account", message: "Go set up an account to get started socializing", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion:nil)
            })
        }
    }
    
    @IBAction func contactUsButtonTapped(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["sorennelson33@gmail.com"])
            mail.setSubject("Socialize")
            presentViewController(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Something is wrong with your mail settings", message: "You can contact us via the app store.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}





