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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var keyboardView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet var constraint: NSLayoutConstraint!
    var conversation: Conversation?
    var convoRecord: CKRecord?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.whiteColor()
        messageTextView.delegate = self
        setNavBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversation?.theMessages.count == nil {
            return 0
        } else {
            print(conversation?.theMessages.count)
            return conversation!.theMessages.count
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
//        fix
        let message = conversation!.theMessages[indexPath.row]
        
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
                meMessageCell.userIcon.image = image
            } else {
                meMessageCell.userIcon?.image = UIImage(named: "Contact")
            }
            return themMessageCell
        }

    }
    
    override var inputAccessoryView: UIView {
//        constraint.constant = 216
        keyboardView.frame.size.height = messageTextView.contentSize.height + 18
        keyboardView.autoresizingMask = .FlexibleHeight
        return keyboardView
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    let minKeyboardViewHeight = CGFloat(36)
    let maxKeyboardViewHeight = CGFloat(144)
    
    func textViewDidChange(textView: UITextView) {
        let height = ceil(messageTextView.contentSize.height + 4)
        if height > maxKeyboardViewHeight {
            messageTextView.frame.size.height = maxKeyboardViewHeight
            keyboardView.frame.size.height = maxKeyboardViewHeight + 14
        }
        if height != messageTextView.frame.size.height {
            messageTextView.frame.size.height = height
            keyboardView.frame.size.height = height + 14
        }
        self.reloadInputViews()
    }
    
    @IBAction func sendMessageTapped(sender: AnyObject) {
        if messageTextView.text.isEmpty == false {
            var message: Message
            let userpic = UserController.sharedInstance.myRelationship?.profilePic?.image
            message = Message(senderUID: UserController.sharedInstance.myRelationship!.userID, messageText: messageTextView.text, time: nil, userPic: userpic)
            MessageController.postMessage(message) { (success, messageRecord) in
                if success {
                    if let record = self.convoRecord, conversation = self.conversation {
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
//                                            
//                                            
//                                            
                                        })
                                    }
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.messageTextView.text = ""
                                        self.conversation?.theMessages += [message]
                                        self.conversation?.lastMessage = message
                                        self.conversation?.messages = messages
                                        self.tableView.reloadData()
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
                                        self.tableView.reloadData()
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




