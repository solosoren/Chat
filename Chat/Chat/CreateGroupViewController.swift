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
    
    @IBOutlet weak var groupTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setNavBar()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCellWithReuseIdentifier("addContact", forIndexPath: indexPath)
        return item
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
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
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        let currentUserRef = CKReference(recordID: UserController.sharedInstance.currentUser!.userID, action: CKReferenceAction.None)
        let conversation = Conversation.init(convoName: groupTitle.text!, users: [currentUserRef])
        ConversationController.createConversation(conversation) { (success) in
            if success {
                print("It Worked!")
                print("CONVERSATION: \(conversation)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: {
                        
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
