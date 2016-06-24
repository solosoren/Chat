//
//  LoginViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/29/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

class LoginViewController: UIViewController {
            
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
            self.iCloudLogin { (success) in
            if success {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.performSegueWithIdentifier("addPhoto", sender: self)
//                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                print("Not this time")
            }
        }
    }
    
    func iCloudLogin(completion:(success: Bool) -> Void) {
        UserController.sharedInstance.requestPermission { (success) in
            if success {
                UserController.sharedInstance.fetchUser({ (success, user) in
                    if success {
                        UserController.sharedInstance.fetchUserInfoAndSetUserName(user!, completion: { (success, user) in
                            if success {
                                UserController.sharedInstance.currentUser = user
                                UserController.sharedInstance.createRelationship({ (success) in
                                    if success {
                                        completion(success: true)
                                    } else {
                                        completion(success: false)
                                    }
                                })
                                
                                completion(success: true)
                            } else {
                                completion(success: false)
                            }
                        })
                    } else {
//                        error handling
                        completion(success: false)
                        print("Didn't Work")
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { 
                    let iCloudAlert = UIAlertController(title: "iCloud Error", message: "Error connecting to iCloud. Check iCloud settings by going to Settings > iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    iCloudAlert.addAction(ok)
                    self.presentViewController(iCloudAlert, animated: true, completion: nil)
                })
            }
        }
    }

    
}
