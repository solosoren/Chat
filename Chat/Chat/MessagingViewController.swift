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
    var conversation: Conversation?
    var convoRecord: CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.whiteColor()
        self.setNavBar()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let messages = convoRecord!["Messages"] as! [CKReference]
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let messagesRef = convoRecord!["Messages"] as! [CKReference]
        let messageRef = messagesRef[indexPath.row]
        let messageRecord = CKRecord(recordType: "Message", recordID: messageRef.recordID)
        let sender = messageRecord["SenderUID"] as! CKReference
        
        if sender != UserController.sharedInstance.myRelationship?.userID {
            let themMessageCell = tableView.dequeueReusableCellWithIdentifier("themMessageCell", forIndexPath: indexPath) as! ThemMessageTableViewCell
            themMessageCell.messageText.text = messageRecord["MessageText"] as? String
//            image
            return themMessageCell

        } else {
            let meMessageCell = tableView.dequeueReusableCellWithIdentifier("meMessageCell", forIndexPath: indexPath) as! MeMessageTableViewCell
            meMessageCell.messageText.text = messageRecord["MessageText"] as? String
//            image
            return meMessageCell
        }
        
    }
    
    override var inputAccessoryView: UIView {
        return keyboardView
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    @IBAction func sendMessageTapped(sender: AnyObject) {
        if messageTextView.text.isEmpty == false {
            dispatch_async(dispatch_get_main_queue(), { 
                self.messageTextView.resignFirstResponder()
            })
            let message = Message(senderUID: UserController.sharedInstance.myRelationship!.userID, messageText: messageTextView.text)
            MessageController.postMessage(message) { (success, messageRecord) in
                if success {
                    let record = self.convoRecord
                    let ref = CKReference(record: messageRecord!, action: .DeleteSelf)
                    if self.conversation!.messages! != [] {
                        var messages = record!["Messages"] as! [CKReference]
                        messages += [ref]
                        record!.setValue(messages, forKey: "Messages")
                        let mod = CKModifyRecordsOperation(recordsToSave: [record!], recordIDsToDelete: nil)
                        mod.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                            if error == nil {
                                print("It Worked!")
                                print(message.senderUID)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.messageTextView.text = ""
                                    self.conversation?.messages! += messages
                                    self.tableView.reloadData()
                                })
                            } else {
                                print("ERROR SAVING MESSAGES TO CONVO: \(error!.localizedDescription)")
                            }
                        }
                        CKContainer.defaultContainer().publicCloudDatabase.addOperation(mod)

                    } else {
                        let messages = [ref]
                        record!.setValue(messages, forKey: "Messages")
                        let mod = CKModifyRecordsOperation(recordsToSave: [record!], recordIDsToDelete: nil)
                        mod.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                            if error == nil {
                                print("It Worked!")
                                print(message.senderUID)
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.messageTextView.text = ""
                                    self.conversation?.messages! = messages
                                    self.tableView.reloadData()
                                })
                            } else {
                                
                                print("ERROR SAVING MESSAGES TO CONVO: \(error!.localizedDescription)")
                            }
                        }
                        CKContainer.defaultContainer().publicCloudDatabase.addOperation(mod)
                    }
                    
                } else {
                    print("Not this time")
                }
            }
        }
    }
    
}

