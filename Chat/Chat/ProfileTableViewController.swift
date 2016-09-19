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
        DispatchQueue.main.async {
            if let asset = UserController.sharedInstance.myRelationship?.profilePic {
                self.profilePic.image = asset.image
            }
        }
    }
    
    func setProfileNavBar() {
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 0, green: 0.384, blue: 0.608, alpha: 1.0)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        if let fullName = UserController.sharedInstance.currentUser?.fullName {
            navigationItem.title = fullName
        } else {
            navigationItem.title = "Socialize"
        }
    }
    
    func noAccount() {
        if UserController.sharedInstance.myRelationship == nil {
            DispatchQueue.main.async(execute: { 
                let alert = UIAlertController(title: "No Account", message: "Go set up an account to get started socializing", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion:nil)
            })
        }
    }
    
    @IBAction func contactUsButtonTapped(_ sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["sorennelson33@gmail.com"])
            mail.setSubject("Socialize")
            present(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Something is wrong with your mail settings", message: "You can contact us via the app store.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}





