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
    
    static func createConversation(conversation:Conversation, completion:(success:Bool, record: CKRecord?) -> Void) {
        let record = CKRecord(recordType: "Conversation")
        record.setValuesForKeysWithDictionary(conversation.toAnyObject() as! [String : AnyObject])
        record["Messages"] = []
        let container = CKContainer.defaultContainer()
        container.publicCloudDatabase.saveRecord(record) { (conversation, error) in
            if error == nil {
                completion(success: true, record: record)

            } else {
                print("error: \(error?.localizedDescription)")
                completion(success: false, record: nil)
//                handle error
            }
            
        }
    }
    
    func grabUserConversations(relationship:Relationship, completion:(success:Bool, conversations:[Conversation]?, convoRecords:[CKRecord]?) -> Void) {
        var conversations: [Conversation] = []
        let container = CKContainer.defaultContainer()
        let pred = NSPredicate(format: "Users CONTAINS %@", relationship.userID)
        let query = CKQuery(recordType: "Conversation", predicate: pred)
        container.publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (records, error) in
            if error == nil {
                NSLog("SSSSSSSSSSSSS: 5A")
                if records?.count != 0 {
                    for record in records! {
                        self.subscribeToConversations(record, completion: { (success) in
                            if success {
                                var conversation = Conversation(convoName: record["GroupName"] as? String, users: record["Users"] as! [CKReference], messages: record["Messages"] as? [CKReference])
                                conversation.ref = record.recordID

                                if conversation.messages?.count != 0 {
                                    container.publicCloudDatabase.fetchRecordWithID((conversation.messages?.last?.recordID)!, completionHandler: { (lastRecord, error) in
                                        if error == nil {
                                            let message = Message(senderUID: lastRecord!["SenderUID"] as! CKReference, messageText: lastRecord!["MessageText"] as! String)
                                            conversation.lastMessage = message
                                            conversations += [conversation]
                                            if record == records?.last {
                                                completion(success: true, conversations: conversations, convoRecords: records)
                                            }
                                        } else {
                                            completion(success: false, conversations: conversations, convoRecords: nil)
                                        }
                                        
                                    })
                                } else {
                                    conversations += [conversation]
                                    if record == records?.last {
                                        completion(success: true, conversations: conversations, convoRecords: records)
                                    }
                                }
                            } else {
                                completion(success: false, conversations: conversations, convoRecords: [])
                            }
                        })
                    }
                } else {
//                    getting to this
                    completion(success: true, conversations: conversations, convoRecords: [])
                }
                
                
            } else {
                print("ERROR: \(error?.localizedDescription)")
                completion(success: true, conversations: conversations, convoRecords: [])
            }
        }
    }
    
    func subscribeToConversations(conversationRecord: CKRecord, completion:(success:Bool) -> Void) {
        
        NSLog("MADE IT TO SUBSCRIPTION")
        let pred = NSPredicate(format: "Users CONTAINS %@", UserController.sharedInstance.myRelationship!.userID)
        NSLog("PRED")
        let sub = CKSubscription(recordType: "Conversation", predicate: pred, subscriptionID: "\(conversationRecord.recordID)A", options: .FiresOnRecordUpdate)
        NSLog("SUB")
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        publicDatabase.saveSubscription(sub) { (subscription, error) in
            if let subscription = subscription {
                NSLog("SUBSCRIPTION: \(subscription)")
                completion(success: true)
            } else {
                NSLog("ERROR: \(error)")
                completion(success: true)
            }
        }
        
    }

}




