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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func addImageTapped(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { 
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.imageView.image = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        imageView.contentMode = .ScaleToFill
        dismissViewControllerAnimated(true) {
            self.addImageButton.hidden = true
        }
        
    }
    
    @IBAction func saveImageTapped(sender: AnyObject) {
        if self.imageView.image != nil {
            dispatch_async(dispatch_get_main_queue(), { 
                UserController.sharedInstance.fetchRecord { (success, record) in
                    if success {
                        do {
                            let asset = try CKAsset(image: self.imageView.image!)
                            record!["ImageKey"] = asset
                        }
                        catch {
                            print("Error creating assets", error)
                        }
                        
                        CKContainer.defaultContainer().privateCloudDatabase.saveRecord(record!, completionHandler: { (record, error) in
                            if error == nil {
                                self.performSegueWithIdentifier("loggedIn", sender: self)
                            } else {
                                print("Shit went wrong")
                            }
                        })
                    } else {
                        print("Nope")
                    }
                }
            })
        } else {
            
        }
        
        
    }
    
    
}




