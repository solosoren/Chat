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
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        self.iCloudLogin { (success) in
            if success {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    indicator.stopAnimating()
                    let alert = UIAlertController(title: nil, message: "Successful iCloud Login", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Cool", style: .Default, handler: { (action) in
                        self.performSegueWithIdentifier("addPhoto", sender: self)
                    })
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    indicator.stopAnimating()
                    let alert = UIAlertController(title: "Oops", message: "iCloud Login failed", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
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
                                UserController.sharedInstance.createRelationship(user!, completion: { (success) in
                                    if success {
                                        completion(success: true)
                                    } else {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            let alert = UIAlertController(title: "Couldn't Create Relationship", message: "Tell Soren it didn't work!", preferredStyle: .Alert)
                                            let action = UIAlertAction(title: "Will Do", style: .Default, handler: nil)
                                            alert.addAction(action)
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })
                                        completion(success: false)
                                    }
                                })
                            } else {
                                dispatch_async(dispatch_get_main_queue(), { 
                                    let alert = UIAlertController(title: "Oops", message: "There was an issue fetching your user info", preferredStyle: .Alert)
                                    let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                                    alert.addAction(action)
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                                completion(success: false)
                            }
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { 
                            let alert = UIAlertController(title: "Oops", message: "There was an issue fetching your account", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                        completion(success: false)
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { 
                    let iCloudAlert = UIAlertController(title: "iCloud Error", message: "Error connecting to iCloud. Check iCloud settings by going to Settings > iCloud.", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    iCloudAlert.addAction(ok)
                    self.presentViewController(iCloudAlert, animated: true, completion: nil)
                })
                completion(success: false)
            }
        }
    }
}
