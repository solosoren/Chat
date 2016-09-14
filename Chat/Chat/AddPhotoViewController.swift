//
//  AddPhotoViewController.swift
//  Chat
//
//  Created by Soren Nelson on 5/20/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class AddPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var backgroundToImage: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    var defaultContainer: CKContainer?
    @IBOutlet var saveImageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundToImage.hidden = true
        saveImageButton.layer.borderWidth = 2
        saveImageButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func addImageTapped(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) { 
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imageView.image = (info[UIImagePickerControllerEditedImage] as! UIImage)
        imageView.contentMode = .ScaleToFill
        dismissViewControllerAnimated(true) {
            self.addImageButton.hidden = true
            self.backgroundToImage.hidden = false
        }
        
    }
    
    @IBAction func saveImageTapped(sender: AnyObject) {
        if imageView.image != nil {
//        TODO: fix activity indicator throughout
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            indicator.center = view.center
            view.addSubview(indicator)
            indicator.startAnimating()
            saveImage({ (success, record) in

                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: "One last thing", message: "Would you like to add all your contacts that are already Socializing", preferredStyle: .Alert)
                        let yes = UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
                            
                            UserController.sharedInstance.setFriends(UserController.sharedInstance.currentUser!, record: record!, completion: { (success, user) in
                                if success {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        indicator.stopAnimating()
                                        let successAlert = UIAlertController(title: "Account Created", message: "Enjoy Socializing", preferredStyle: .Alert)
                                        let ok = UIAlertAction(title: "Okay", style: .Default, handler: {
                                            (action) in
                                            self.performSegueWithIdentifier("loggedIn", sender: self)
                                        })
                                        successAlert.addAction(ok)
                                        self.presentViewController(successAlert, animated: true, completion:nil)
                                    })
                                } else {
//         TODO: add where they can go to try again to get friends
                                    dispatch_async(dispatch_get_main_queue(), {
                                        indicator.stopAnimating()
                                        let unsuccessful = UIAlertController(title: "Uh Oh", message: "We are having troubles getting your contacts", preferredStyle: .Alert)
                                        let action = UIAlertAction(title: "Okay", style: .Default, handler: { (action) in
                                            self.performSegueWithIdentifier("loggedIn", sender: self)
                                        })
                                        unsuccessful.addAction(action)
                                        self.presentViewController(unsuccessful, animated: true, completion: nil)
                                    })
                                }
                            })
                        })
                        dispatch_async(dispatch_get_main_queue(), { 
                            let no = UIAlertAction(title: "No", style: .Cancel, handler: { (action) in
                                indicator.stopAnimating()
                                let successAlert = UIAlertController(title: "Account Created", message: "Enjoy Socializing", preferredStyle: .Alert)
                                let ok = UIAlertAction(title: "Okay", style: .Default, handler: {
                                    (action) in
                                    self.performSegueWithIdentifier("loggedIn", sender: self)
                                })
                                successAlert.addAction(ok)
                                self.presentViewController(successAlert, animated: true, completion:nil)
                            })
                            
                            alert.addAction(yes)
                            alert.addAction(no)
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    })
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), { 
                        let errorAlert = UIAlertController(title: "Oops", message: "Error adding profile image to account", preferredStyle: .Alert)
                        let retry = UIAlertAction(title: "Retry", style: .Default, handler: nil)
                        errorAlert.addAction(retry)
//                    TODO: fix?
                        let ignore = UIAlertAction(title: "Continue without one", style: .Default, handler: { (action) in
                            self.performSegueWithIdentifier("loggedIn", sender: self)
                        })
                        errorAlert.addAction(ignore)
                        self.presentViewController(errorAlert, animated: true, completion: nil)
                    })
                }
            })
            
        } else {
            dispatch_async(dispatch_get_main_queue(), { 
                let noImageAlert = UIAlertController(title: "No Image", message: "Add a photo to continue", preferredStyle: .Alert)
                let ok = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                noImageAlert.addAction(ok)
                self.presentViewController(noImageAlert, animated: true, completion: nil)
            })
            
        }
        
        
    }
    
    func saveImage(completion:(success:Bool, record: CKRecord?) -> Void) {
        UserController.sharedInstance.queryForMyRelationship(UserController.sharedInstance.currentUser!) { (success, record) in
            if success {
                do {
                    let asset = try CKAsset(image: self.imageView.image!)
                    record!["ImageKey"] = asset
                }
                catch {
                    print("Error creating assets", error)
                    completion(success: false, record: nil)
                }
                CKContainer.defaultContainer().publicCloudDatabase.saveRecord(record!, completionHandler: { (record, error) in
                    if error == nil {
                        completion(success: true, record: record)
                    } else {
                        completion(success: false, record: nil)
                    }
                })
            } else {
                completion(success: false, record: nil)
            }
        }
    }
    
//    figure out how to get record so I can ask if they want to add friends
    @IBAction func skipButtonTapped(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            let successAlert = UIAlertController(title: "Account Created", message: "Enjoy Socializing", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Okay", style: .Default, handler: {
                (action) in
                self.performSegueWithIdentifier("loggedIn", sender: self)
            })
            successAlert.addAction(ok)
            self.presentViewController(successAlert, animated: true, completion:nil)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        let destinationVC = navController.topViewController as! HomeViewController
        destinationVC.demo = true
    }
    
}




