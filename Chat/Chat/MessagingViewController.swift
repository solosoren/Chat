//
//  MessagingViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

class MessagingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tableView: TableView!
    var newConstraint: NSLayoutConstraint?
    @IBOutlet var keyboardInputView: UIView!
    @IBOutlet var keyboardView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet var constraint: NSLayoutConstraint!
    var conversation: Conversation?
    var convoRecord: CKRecord?
    var demo = false
    var skippedLogin = false
    @IBOutlet var keyboardViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.whiteColor()
        messageTextView.delegate = self
        sendButton.layer.borderColor = UIColor.whiteColor().CGColor
        sendButton.layer.borderWidth = 1.0
        setNavBar()
        if demo {
            sendButton.enabled = false
        } else if skippedLogin {
            sendButton.enabled = false
        }
        sendButton.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagingViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagingViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
        
    
    
//    MARK: Tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let conversation = conversation {
            return conversation.theMessages.count
            
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
//    fix message record
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let themMessageCell = tableView.dequeueReusableCellWithIdentifier("themMessageCell", forIndexPath: indexPath) as! ThemMessageTableViewCell
        let meMessageCell = tableView.dequeueReusableCellWithIdentifier("meMessageCell", forIndexPath: indexPath) as! MeMessageTableViewCell
        
//    fix
        if let conversation = conversation {
            
            let message = conversation.theMessages[indexPath.row]
            
            if message.senderUID == UserController.sharedInstance.myRelationship?.userID {
                meMessageCell.messageText.text = message.messageText
                if let image = message.userPic {
                    meMessageCell.userIcon.image = image
                } else {
                    meMessageCell.userIcon?.image = UIImage(named: "Contact")
                }
                return meMessageCell
            } else {
                themMessageCell.messageText.text = message.messageText
                if let image = message.userPic {
                    themMessageCell.userIcon.image = image
                } else {
                    themMessageCell.userIcon?.image = UIImage(named: "Contact")
                }
                return themMessageCell
            }
        } else if demo {
            return themMessageCell
        } else if skippedLogin {
            themMessageCell.messageText.text = "Create an account to get started socializing."
            return themMessageCell
        } else {
            themMessageCell.messageText.text = "Loading..."
            return themMessageCell
        }
    }
    
    func keyboardWasShown(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            constraint.constant = keyboardSize.height
            UIView.animateWithDuration(0.3) {
                self.tableView.layoutIfNeeded()
            }
        }
        tableView.reloadData(conversation)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if constraint.constant != 52 {
                self.constraint.constant -= keyboardSize.height
            }
        }
        keyboardViewHeightConstraint.constant = messageTextView.frame.size.height + 14
        resignFirstResponder()
        tableView.reloadData(conversation)
    }
    
//    MARK: Input Accessory View
    override var inputAccessoryView: UIView {
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.layoutIfNeeded()
        
        let fixedWidth = messageTextView.frame.size.width
        let newSize = messageTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = messageTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        messageTextView.frame = newFrame

//        keyboardView.frame.size.height = self.messageTextView.frame.size.height + 14
        keyboardViewHeightConstraint.constant = messageTextView.frame.size.height + 14
        keyboardView.autoresizingMask = .FlexibleHeight
        return keyboardInputView
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if messageTextView.text.isEmpty {
            sendButton.enabled = false
        } else {
            sendButton.enabled = true
        }
        if messageTextView.contentSize.height > 200 {
            messageTextView.frame.size.height = 200
        }
        dispatch_async(dispatch_get_main_queue()) { 
            if self.keyboardView.frame.size.height != self.messageTextView.frame.size.height + 14 {
                self.keyboardViewHeightConstraint.constant = self.messageTextView.frame.size.height + 14
                self.reloadInputViews()
            }
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        tableView.reloadData(conversation)
        constraint.constant = keyboardView.frame.size.height + 2
    }
    
    
//    MARK: Send Button
    @IBAction func sendMessageTapped(sender: AnyObject) {
        var message: Message
        if messageTextView.text.isEmpty == false {
            let userpic = UserController.sharedInstance.myRelationship?.profilePic?.image
            message = Message(senderUID: UserController.sharedInstance.myRelationship!.userID, messageText: messageTextView.text, time: nil, userPic: userpic)
            MessageController.postMessage(message) { (success, messageRecord) in
                if success {
                    if let record = self.convoRecord, let conversation = self.conversation {
                        let ref = CKReference(record: messageRecord!, action: .DeleteSelf)
                        if conversation.messages != nil {
                            var messages = record["Messages"] as! [CKReference]
                            messages += [ref]
                            record.setValue(messages, forKey: "Messages")
                            let mod = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                            mod.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                                if error == nil {
                                    if conversation.theMessages.isEmpty == true {
                                        ConversationController.sharedInstance.subscribeToConversations(self.convoRecord!, contentAvailable: true, completion: { (success) in
                                        })
                                    }
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.messageTextView.text = ""
                                        self.keyboardView.frame.size.height = self.messageTextView.frame.size.height + 14
                                        self.conversation?.theMessages += [message]
                                        self.conversation?.lastMessage = message
                                        self.conversation?.messages = messages
                                        self.keyboardViewHeightConstraint.constant = self.messageTextView.frame.size.height + 14
                                        
                                        self.tableView.reloadData(self.conversation)
                                        self.resignFirstResponder()
                                    })
                                } else {
                                    print("ERROR SAVING MESSAGES TO CONVO: \(error!.localizedDescription)")
                                }
                            }
                            CKContainer.defaultContainer().publicCloudDatabase.addOperation(mod)
                            
                        } else {
                            let messages = [ref]
                            record.setValue(messages, forKey: "Messages")
                            let mod = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                            mod.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                                if error == nil {
                                    print("It Worked!")
                                    print(message.senderUID)
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.messageTextView.text = ""
                                        self.conversation?.messages! = messages
                                        self.conversation?.theMessages = [message]
                                        self.conversation?.lastMessage = message
                                        self.tableView.reloadData(self.conversation)
                                    })
                                } else {
                                    print("ERROR SAVING MESSAGES TO CONVO: \(error!.localizedDescription)")
                                }
                            }
                            CKContainer.defaultContainer().publicCloudDatabase.addOperation(mod)
                        }
                        
                    }
                } else {
                    print("Not this time")
                }
            }
        }
    }
 
}

class TableView: UITableView {
    
    func reloadData(conversation:Conversation?) {
        super.reloadData()
        if let conversation = conversation {
            let index = NSIndexPath(forRow: conversation.theMessages.count - 1, inSection: 0)
            scrollToRowAtIndexPath(index, atScrollPosition: .None, animated: true)
        }
    }
}




