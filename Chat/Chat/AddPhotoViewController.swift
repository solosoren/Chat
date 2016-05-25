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
    let progressIndicatorView = LoaderAnimation(frame: CGRectZero)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundToImage.hidden = true
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
        self.imageView.image = (info[UIImagePickerControllerEditedImage] as! UIImage)
        imageView.contentMode = .ScaleToFill
        dismissViewControllerAnimated(true) {
            self.addImageButton.hidden = true
            self.backgroundToImage.hidden = false
        }
        
    }
    
    @IBAction func saveImageTapped(sender: AnyObject) {
        if self.imageView.image != nil {
            view.addSubview(self.progressIndicatorView)
            progressIndicatorView.frame = view.bounds
            progressIndicatorView.autoresizingMask = .FlexibleWidth
            progressIndicatorView.autoresizingMask = .FlexibleHeight
            self.saveImage({ (success) in
//                    loading animation

                if success {
                    self.progressIndicatorView.progress = 1
                    dispatch_async(dispatch_get_main_queue(), { 
                        let successAlert = UIAlertController(title: "Account Created", message: "Enjoy Socializing", preferredStyle: .Alert)
                        let ok = UIAlertAction(title: "Okay", style: .Cancel, handler: {
                            (action) in
                            self.performSegueWithIdentifier("loggedIn", sender: self)
                        })
                        successAlert.addAction(ok)
                        self.presentViewController(successAlert, animated: true, completion:nil)
                    })
                    
                } else {
                    let errorAlert = UIAlertController(title: "Oops", message: "Error adding profile image to account", preferredStyle: .Alert)
                    let retry = UIAlertAction(title: "Retry", style: .Default, handler: nil)
                    errorAlert.addAction(retry)
                    let ignore = UIAlertAction(title: "Continue without one", style: .Default, handler: { (action) in
                        self.performSegueWithIdentifier("loggedIn", sender: self)
                    })
                    errorAlert.addAction(ignore)
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
                
            })
            
        } else {
            let noImageAlert = UIAlertController(title: "No Image", message: "Add a photo to continue", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            noImageAlert.addAction(ok)
            self.presentViewController(noImageAlert, animated: true, completion: nil)
        }
        
        
    }
    
    func saveImage(completion:(success:Bool) -> Void) {
        UserController.sharedInstance.fetchRecord { (success, record) in
            if success {
                do {
                    let asset = try CKAsset(image: self.imageView.image!)
                    record!["ImageKey"] = asset
                }
                catch {
                    print("Error creating assets", error)
                    completion(success: false)
                }
                
                CKContainer.defaultContainer().privateCloudDatabase.saveRecord(record!, completionHandler: { (record, error) in
                    if error == nil {
                        completion(success: true)
                    } else {
                        completion(success: false)
                    }
                })
            } else {
                completion(success: false)
            }
        }
    }
    
    @IBAction func skipButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("loggedIn", sender: self)
        
    }
    
}




