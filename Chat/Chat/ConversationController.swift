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
    var myConversations: [Conversation] = []
    
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
                if records?.count != 0 {
                    for record in records! {
//                        fix alert body
                        self.subscribeToConversations(record, contentAvailable: true, alertBody: "You have a new message", completion: { (success) in
                            if success {
                                var conversation = Conversation(record: record)
                                conversation.ref = record.recordID

                                if conversation.messages?.count != 0 {
                                    for thing in conversation.messages! {
                                        container.publicCloudDatabase.fetchRecordWithID((thing.recordID), completionHandler: { (messageRecord, error) in
                                            if error == nil {
                                                let string = Timer.sharedInstance.setMessageTime(messageRecord!)
                                                var message = Message(record: messageRecord!)
                                                message.time = string
                                                conversation.theMessages += [message]
                                                if thing == conversation.messages?.last {
                                                    conversation.lastMessage = message
                                                    conversations += [conversation]
                                                    if record == records?.last {
                                                        completion(success: true, conversations: conversations, convoRecords: records)
                                                    }
                                                }
                                            } else {
                                                completion(success: false, conversations: conversations, convoRecords: nil)
                                            }
                                        })
                                    }
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
    
    func subscribeToConversations(conversationRecord:CKRecord, contentAvailable:Bool, alertBody:String? = nil, completion:(success:Bool) -> Void) {
        
        let pred = NSPredicate(format: "Users CONTAINS %@", UserController.sharedInstance.myRelationship!.userID)
        let sub = CKSubscription(recordType: "Conversation", predicate: pred, subscriptionID: "\(conversationRecord.recordID)A", options: [.FiresOnRecordUpdate, .FiresOnRecordCreation])

        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        notificationInfo.shouldSendContentAvailable = contentAvailable
        sub.notificationInfo = notificationInfo
        
        let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
        publicDatabase.saveSubscription(sub) { (subscription, error) in
            if subscription != nil {
                completion(success: true)
            } else {
//                FIX
                NSLog("ERROR: \(error)")
                completion(success: true)
            }
        }
        
    }
    
    func subscribe(type: String, predicate: NSPredicate, subscriptionID: String, contentAvailable: Bool, alertBody: String? = nil, desiredKeys: [String]? = nil, options: CKSubscriptionOptions, completion: ((subscription: CKSubscription?, error: NSError?) -> Void)?) {
        
        let subscription = CKSubscription(recordType: type, predicate: predicate, subscriptionID: subscriptionID, options: options)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        notificationInfo.shouldSendContentAvailable = contentAvailable
        notificationInfo.desiredKeys = desiredKeys
        
        subscription.notificationInfo = notificationInfo
        
        CKContainer.defaultContainer().publicCloudDatabase.saveSubscription(subscription) { (subscription, error) in
            
            if let completion = completion {
                completion(subscription: subscription, error: error)
            }
        }
    }
    
    func fetchSubscription(subscriptionID: String, completion: ((subscription: CKSubscription?, error: NSError?) -> Void)?) {
        CKContainer.defaultContainer().publicCloudDatabase.fetchSubscriptionWithID(subscriptionID) { (subscription, error) in
            if let completion = completion {
                completion(subscription: subscription, error: error)
            }
        }
    }
    
    func checksubscriptionToConversation(conversationRecord:CKRecord, completion:((subscribed:Bool) -> Void)?) {
        fetchSubscription(("\(conversationRecord.recordID)A")) { (subscription, error) in
            if let completion = completion {
                let subscribed = subscription != nil
                completion(subscribed: subscribed)
            }
        }
    }
    
    func unsubscribeFromConversation(subscriptionID: String, completion:((subscriptionID: String?, error:NSError?) -> Void)?) {
        CKContainer.defaultContainer().publicCloudDatabase.deleteSubscriptionWithID(subscriptionID) { (subscriptionID, error) in
            
            if let completion = completion {
                completion(subscriptionID: subscriptionID, error: error)
            }
        }
    }
    
//    call when delete row?
//    maybe in info button
    func removeSubscriptionFromConversation(conversationRecord:CKRecord, completion:((success:Bool, error:NSError?) -> Void)?) {
        unsubscribeFromConversation(("\(conversationRecord.recordID)A")) { (subscriptionID, error) in
            if let completion = completion {
                let success = subscriptionID != nil
                completion(success: success, error: error)
            }
        }
    }

}




