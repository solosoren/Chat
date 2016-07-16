//
//  CreateGroupViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/12/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

class CreateGroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var groupTitle: UITextField!
    var contacts:[Relationship]?
    var initialContact:Relationship?
    var selectedContacts: [Relationship]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setNavBar()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCellWithReuseIdentifier("addContact", forIndexPath: indexPath) as! CreateGroupCollectionViewCell
        item.nameLabel.text = contacts![indexPath.item].fullName
        if let asset = contacts![indexPath.item].profilePic {
            item.profilePic.image = asset.image
        }
        item.addButton.tag = indexPath.item
//        this might be a problem
        
        if item.nameLabel.text == initialContact?.fullName {
            dispatch_async(dispatch_get_main_queue(), { 
                item.addButton.imageView?.image = UIImage(named: "Checked")
            })
            if selectedContacts != nil {
                selectedContacts! += [initialContact!]
            } else {
                selectedContacts = [initialContact!]
            }
        }
        
        return item
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts!.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let size = CGSize(width:(self.view.bounds.width / 2) - 5, height:130)
        return size
    }
    
    @IBAction func dismissButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        let selectedContact = contacts![sender.tag]
        if selectedContacts != nil {
            selectedContacts! += [selectedContact]
        } else {
            selectedContacts = [selectedContact]
        }
        let item: CreateGroupCollectionViewCell
        let indexPath = NSIndexPath(forItem: sender.tag, inSection: 0)
        item = collectionView.cellForItemAtIndexPath(indexPath) as! CreateGroupCollectionViewCell
        dispatch_async(dispatch_get_main_queue()) { 
            item.addButton.imageView?.image = UIImage(named: "Checked")
//            self.collectionView.reloadData()
        }
    }
    
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        let currentUserRef = CKReference(recordID: UserController.sharedInstance.currentUser!.userID, action: CKReferenceAction.None)
        
        var selectedRef = [currentUserRef]
        for relationship in selectedContacts! {
            selectedRef += [relationship.userID]
        }
        let conversation = Conversation.init(convoName: groupTitle.text!, users: selectedRef, messages: [])
        ConversationController.createConversation(conversation) { (success, record) in
            if success {
                print("It Worked!")
                print("CONVERSATION: \(conversation)")
                dispatch_async(dispatch_get_main_queue(), {
//                    TODO: need to fixxx!!!
                    self.dismissViewControllerAnimated(true, completion: {
                        let messageView = MessagingViewController()
                        self.performSegueWithIdentifier("groupCreated", sender: self)
                        messageView.conversation = conversation
                        messageView.convoRecord = record
                    })
                })
            } else {
                print("Not this time")
            }
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}





