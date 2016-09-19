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
    var conversation: Conversation?
    var convoRecord: CKRecord?
    
    @IBAction func unwindToGroup(_ segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setNavBar()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "addContact", for: indexPath) as! CreateGroupCollectionViewCell
        item.nameLabel.text = contacts![(indexPath as NSIndexPath).item].fullName
        item.checked = false
        if let asset = contacts![(indexPath as NSIndexPath).item].profilePic {
            item.profilePic.image = asset.image
        }
        item.addButton.tag = (indexPath as NSIndexPath).item
        
        if item.nameLabel.text == initialContact?.fullName {
            DispatchQueue.main.async(execute: { 
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width:(self.view.bounds.width / 3) - 20, height:130)
        return size
    }
    
    @IBAction func dismissButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        var item = CreateGroupCollectionViewCell()
        let indexPath = IndexPath(item: sender.tag, section: 0)
        item = collectionView.cellForItem(at: indexPath) as! CreateGroupCollectionViewCell
        if item.checked == false {
            let selectedContact = contacts![sender.tag]
            if selectedContacts != nil {
                selectedContacts! += [selectedContact]
            } else {
                selectedContacts = [selectedContact]
            }
            DispatchQueue.main.async {
                item.addButton.imageView?.image = UIImage(named: "Checked")
                item.checked = true
            }
        } else {
            selectedContacts!.remove(at: sender.tag)
            DispatchQueue.main.async(execute: { 
                item.addButton.imageView?.image = UIImage(named: "Plus-50")
                item.checked = false
            })
        }
        
    }
    
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        
        guard let selectedContacts = selectedContacts else {
            let alert = UIAlertController(title: "Tap the + button next to the contacts to add them to group.", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        if selectedContacts.count <= 1 {
            let alert = UIAlertController(title: "You must have more than one contact to create a group.", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(action)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let currentUserRef = CKReference(recordID: UserController.sharedInstance.currentUser!.userID, action: CKReferenceAction.none)
            
            var selectedRef = [currentUserRef]
            var groupName:String
            for relationship in selectedContacts {
                selectedRef += [relationship.userID]
            }
            
            if groupTitle.text == "" {
                var names:[String] = []
                for contact in selectedContacts {
                    names.append(contact.fullName)
                }
                names.append((UserController.sharedInstance.myRelationship?.fullName)!)
                groupName = names.joined(separator: ", ")
                
            } else {
                groupName = groupTitle.text!
            }
            conversation = Conversation.init(convoName: groupName, users: selectedRef, messages: [])
            
            ConversationController.createConversation(conversation!) { (success, record) in
                if success {
                    self.convoRecord = record
                    
                    DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "groupCreated", sender: self)
                    })
                } else {
                    print("Not this time")
                }
            }

        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupCreated" {
            let destinationVC = segue.destination as! MessagingViewController
            destinationVC.conversation = conversation
            destinationVC.conversation?.theMessages = []
            destinationVC.conversation?.messages = []
            destinationVC.convoRecord = convoRecord
            destinationVC.grouped = true
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





