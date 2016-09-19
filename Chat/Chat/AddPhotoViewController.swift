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
        backgroundToImage.isHidden = true
        saveImageButton.layer.borderWidth = 2
        saveImageButton.layer.borderColor = UIColor.white.cgColor
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        DispatchQueue.main.async { 
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = (info[UIImagePickerControllerEditedImage] as! UIImage)
        imageView.contentMode = .scaleToFill
        dismiss(animated: true) {
            self.addImageButton.isHidden = true
            self.backgroundToImage.isHidden = false
        }
        
    }
    
    @IBAction func saveImageTapped(_ sender: AnyObject) {
        if imageView.image != nil {
//        TODO: fix activity indicator throughout
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            indicator.center = view.center
            view.addSubview(indicator)
            indicator.startAnimating()
            saveImage({ (success, record) in

                if success {
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "One last thing", message: "Would you like to add all your contacts that are already Socializing", preferredStyle: .alert)
                        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            
                            UserController.sharedInstance.setFriends(UserController.sharedInstance.currentUser!, record: record!, completion: { (success, user) in
                                if success {
                                    DispatchQueue.main.async(execute: {
                                        indicator.stopAnimating()
                                        let successAlert = UIAlertController(title: "Account Created", message: "Enjoy Socializing", preferredStyle: .alert)
                                        let ok = UIAlertAction(title: "Okay", style: .default, handler: {
                                            (action) in
                                            self.performSegue(withIdentifier: "loggedIn", sender: self)
                                        })
                                        successAlert.addAction(ok)
                                        self.present(successAlert, animated: true, completion:nil)
                                    })
                                } else {
//         TODO: add where they can go to try again to get friends
                                    DispatchQueue.main.async(execute: {
                                        indicator.stopAnimating()
                                        let unsuccessful = UIAlertController(title: "Uh Oh", message: "We are having troubles getting your contacts", preferredStyle: .alert)
                                        let action = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                                            self.performSegue(withIdentifier: "loggedIn", sender: self)
                                        })
                                        unsuccessful.addAction(action)
                                        self.present(unsuccessful, animated: true, completion: nil)
                                    })
                                }
                            })
                        })
                        DispatchQueue.main.async(execute: { 
                            let no = UIAlertAction(title: "No", style: .cancel, handler: { (action) in
                                indicator.stopAnimating()
                                let successAlert = UIAlertController(title: "Account Created", message: "Enjoy Socializing", preferredStyle: .alert)
                                let ok = UIAlertAction(title: "Okay", style: .default, handler: {
                                    (action) in
                                    self.performSegue(withIdentifier: "loggedIn", sender: self)
                                })
                                successAlert.addAction(ok)
                                self.present(successAlert, animated: true, completion:nil)
                            })
                            
                            alert.addAction(yes)
                            alert.addAction(no)
                            self.present(alert, animated: true, completion: nil)
                        })
                    })
                    
                } else {
                    DispatchQueue.main.async(execute: { 
                        let errorAlert = UIAlertController(title: "Oops", message: "Error adding profile image to account", preferredStyle: .alert)
                        let retry = UIAlertAction(title: "Retry", style: .default, handler: nil)
                        errorAlert.addAction(retry)
//                    TODO: fix?
                        let ignore = UIAlertAction(title: "Continue without one", style: .default, handler: { (action) in
                            self.performSegue(withIdentifier: "loggedIn", sender: self)
                        })
                        errorAlert.addAction(ignore)
                        self.present(errorAlert, animated: true, completion: nil)
                    })
                }
            })
            
        } else {
            DispatchQueue.main.async(execute: { 
                let noImageAlert = UIAlertController(title: "No Image", message: "Add a photo to continue", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
                noImageAlert.addAction(ok)
                self.present(noImageAlert, animated: true, completion: nil)
            })
            
        }
        
        
    }
    
    func saveImage(_ completion:@escaping (_ success:Bool, _ record: CKRecord?) -> Void) {
        UserController.sharedInstance.queryForMyRelationship(UserController.sharedInstance.currentUser!) { (success, record) in
            if success {
                do {
                    let asset = try CKAsset(image: self.imageView.image!)
                    record!["ImageKey"] = asset
                }
                catch {
                    print("Error creating assets", error)
                    completion(false, nil)
                }
                CKContainer.default().publicCloudDatabase.save(record!, completionHandler: { (record, error) in
                    if error == nil {
                        completion(true, record)
                    } else {
                        completion(false, nil)
                    }
                })
            } else {
                completion(false, nil)
            }
        }
    }
    
//    figure out how to get record so I can ask if they want to add friends
    @IBAction func skipButtonTapped(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            let successAlert = UIAlertController(title: "Account Created", message: "Enjoy Socializing", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Okay", style: .default, handler: {
                (action) in
                self.performSegue(withIdentifier: "loggedIn", sender: self)
            })
            successAlert.addAction(ok)
            self.present(successAlert, animated: true, completion:nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let destinationVC = navController.topViewController as! HomeViewController
        destinationVC.demo = true
    }
    
}




