//
//  ConversationController.swift
//  Chat
//
//  Created by Soren Nelson on 5/10/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import CloudKit

class ConversationController: NSObject {
    
    static let sharedInstance = ConversationController()
    
    static func createConversation(conversation:Conversation, completion:(success:Bool) -> Void) {
        let record = CKRecord(recordType: "Conversation")
        record.setValuesForKeysWithDictionary(conversation.toAnyObject() as! [String : AnyObject])
        record["Messages"] = []
        let container = CKContainer.defaultContainer()
        container.publicCloudDatabase.saveRecord(record) { (conversation, error) in
            if error == nil {
                let pred = NSPredicate(format: "TRUEPREDICATE")
                
                let subscription = CKSubscription(recordType: "Conversation", predicate: pred, subscriptionID: "\(record.recordID)A", options: .FiresOnRecordUpdate)
                let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
                publicDatabase.saveSubscription(subscription) { (subscription, error) in
                    if error == nil {
                        NSLog("SUBSCRIPTION: \(subscription)")
                        completion(success: true)
                    } else {
                        NSLog("ERROR: \(error?.localizedDescription)")
                        completion(success: false)
                    }
                }

            } else {
                print("error: \(error?.localizedDescription)")
                completion(success: false)
//                handle error
            }
            
        }
    }
    
    func grabUserConversations(relationship:Relationship, completion:(success:Bool, conversations:[Conversation]?) -> Void) {
        var conversations: [Conversation] = []
        let container = CKContainer.defaultContainer()
        let pred = NSPredicate(format: "Users CONTAINS %@", relationship.userID)
        let query = CKQuery(recordType: "Conversation", predicate: pred)
        container.publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (records, error) in
            if error == nil {
                if records?.count != 0 {
                    for record in records! {
                        self.subscribeToConversations(record, completion: { (success) in
                            if success {
                                var conversation = Conversation(convoName: record["GroupName"] as? String, users: record["Users"] as! [CKReference], messages: record["Messages"] as? [CKReference])
                                conversation.ref = record.recordID

                                if conversation.messages?.count != 0 {
                                    let lastRecord = CKRecord(recordType: "Message", recordID: (conversation.messages?.last?.recordID)!)
                                    let message = Message(senderUID: lastRecord["SenderUID"] as! CKReference, messageText: lastRecord["MessageText"] as! String)
                                    conversation.lastMessage = message
                                    conversations += [conversation]
                                    if record == records?.last {
                                        completion(success: true, conversations: conversations)
                                    }
                                    
                                } else {
                                    conversations += [conversation]
                                    completion(success: true, conversations: conversations)
                                }
                            } else {
                                completion(success: false, conversations: nil)
                            }
                        })
                    }
                } else {
                    completion(success: true, conversations: conversations)
                }
                
                
            } else {
                print("ERROR: \(error?.localizedDescription)")
                completion(success: false, conversations: nil)
            }
        }
    }
    
    func subscribeToConversations(conversationRecord: CKRecord, completion:(success:Bool) -> Void) {
        //        figure out how to make it so you dont get notification for your own sent messages??
        
        let pred = NSPredicate(format: "TRUEPREDICATE")
        
        let subscription = CKSubscription(recordType: "Conversation", predicate: pred, subscriptionID: "\(conversationRecord.recordID)A", options: .FiresOnRecordUpdate)
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        publicDatabase.saveSubscription(subscription) { (subscription, error) in
            if let subscription = subscription {
                NSLog("SUBSCRIPTION: \(subscription)")
                completion(success: true)
            } else {
                NSLog("ERROR: \(error?.localizedDescription)")
                completion(success: true)
            }
        }
        
    }

}




