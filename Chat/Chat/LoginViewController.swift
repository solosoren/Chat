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
            
    @IBOutlet var allowButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        allowButton.layer.borderWidth = 2
        allowButton.layer.borderColor = UIColor.white.cgColor
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        DispatchQueue.main.async { 
            self.performSegue(withIdentifier: "skip", sender: self)
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
        
//        TODO: fix activity indicator
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        self.iCloudLogin { (success, user) in
            if success {
                DispatchQueue.main.async { () -> Void in
                    indicator.stopAnimating()
                    let alert = UIAlertController(title: nil, message: "Successful iCloud Login", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cool", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "addPhoto", sender: self)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async(execute: {
                    indicator.stopAnimating()
                    let alert = UIAlertController(title: "Oops", message: "iCloud Login failed", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func iCloudLogin(_ completion:@escaping (_ success: Bool, _ user: User?) -> Void) {
        UserController.sharedInstance.requestPermission { (success) in
            if success {
                UserController.sharedInstance.fetchUser({ (success, user) in
                    if let user = user {
                        UserController.sharedInstance.fetchUserInfoAndSetUserName(user, completion: { (success, user) in
                            if success {
                                if let user = user {
                                    UserController.sharedInstance.currentUser = user
                                    UserController.sharedInstance.createRelationship(user, completion: { (success, ref) in
                                        if success {
                                            completion(true, user)
                                        } else {
                                            DispatchQueue.main.async(execute: {
                                                let alert = UIAlertController(title: "Couldn't Create Relationship", message: "Tell Soren it didn't work!", preferredStyle: .alert)
                                                let action = UIAlertAction(title: "Will Do", style: .default, handler: nil)
                                                alert.addAction(action)
                                                self.present(alert, animated: true, completion: nil)
                                            })
                                            completion(false, nil)
                                        }
                                    })
                                } else {
                                    completion(false, nil)
                                }
                            } else {
                                DispatchQueue.main.async(execute: { 
                                    let alert = UIAlertController(title: "Oops", message: "There was an issue fetching your user info", preferredStyle: .alert)
                                    let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)
                                })
                                completion(false, nil)
                            }
                        })
                    } else {
                        DispatchQueue.main.async(execute: { 
                            let alert = UIAlertController(title: "Oops", message: "There was an issue fetching your account", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                        })
                        completion(false, nil)
                    }
                })
            } else {
                DispatchQueue.main.async(execute: { 
                    let iCloudAlert = UIAlertController(title: "iCloud Error", message: "Error connecting to iCloud. Check iCloud settings by going to Settings -> iCloud.", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    iCloudAlert.addAction(ok)
                    self.present(iCloudAlert, animated: true, completion: nil)
                })
                completion(false, nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "skip" {
            let navController = segue.destination as! UINavigationController
            let destinationVC = navController.topViewController as! HomeViewController
            destinationVC.skippedLogin = true
        }
    }

}





