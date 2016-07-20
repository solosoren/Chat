//
//  ConversationController.swift
//  Chat
//
//  Created by Soren Nelson on 5/10/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import CloudKit
import UIKit

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
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

        container.publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (records, error) in
            if error == nil {
                if records?.count != 0 {
                    
                    for record in records! {
                        print("query")
                        
//                        fix alert body
                        self.subscribeToConversations(record, contentAvailable: true, alertBody: "You have a new message", completion: { (success) in
                            if success {
                                print("subscribed")
                                var conversation = Conversation(record: record)
                                conversation.ref = record.recordID

                                if conversation.messages?.count != 0 {
                                    print("conversation messages")
                                    let ref = conversation.messages?.last
                                    container.publicCloudDatabase.fetchRecordWithID((ref?.recordID)!, completionHandler: { (lastMessageRecord, error) in
                                        if error == nil {
                                            conversation.lastMessage = Message(record: lastMessageRecord!)
                                            conversation.lastMessage?.time = Timer.sharedInstance.setMessageTime(lastMessageRecord!)
                                            conversations += [conversation]
                                            if record == records?.last {
                                                print("DONE")
                                                completion(success: true, conversations: conversations, convoRecords: records)
                                            }

                                        } else {
                                            completion(success: false, conversations: conversations, convoRecords: records)
                                        }
                                    })
                                } else {
                                    conversations += [conversation]
                                    completion(success: true, conversations: conversations, convoRecords: records)
                                }
                            } else {
                                completion(success: false, conversations: nil, convoRecords: nil)
                            }
                        })
                    }
                } else {
                    completion(success: false, conversations: nil, convoRecords: nil)
                }
                
                
            } else {
                print("ERROR: \(error?.localizedDescription)")
                completion(success: false, conversations: nil, convoRecords: nil)
            }
        }
    }
    
    func grabMessages(conversation:Conversation, completion:(success:Bool, conversation: Conversation?, messages:[Message]?) -> Void) {
        let container = CKContainer.defaultContainer()
        var messages: [Message] = []
        if let messageRefs: [CKReference] = conversation.messages {
            if conversation.messages?.count != 0 {
                
                    let pred = NSPredicate(format: "recordID == %@", argumentArray: messageRefs)
                    let query = CKQuery(recordType: "Message", predicate: pred)
                    container.publicCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (messageRecords, error) in
                        print(messageRecords)
                        if error == nil {
                            for messageRecord in messageRecords! {
                                let time = Timer.sharedInstance.setMessageTime(messageRecord)
                                var message = Message(record: messageRecord)
                                message.time = time
                                
                                UserController.sharedInstance.grabImageByUID(message.senderUID.recordID, completion: { (success, image) in
                                    if success {
                                        if image != nil {
                                            message.userPic = image
                                            if messages.count == 0 {
                                                messages = [message]
                                                if messageRecord == messageRecords!.last {
                                                    completion(success: true, conversation: conversation, messages: messages)
                                                }
                                            } else {
                                                messages += [message]
                                                if messageRecord == messageRecords!.last {
                                                    completion(success: true, conversation: conversation, messages: messages)
                                                }
                                            }
                                            
                                            
                                        } else {
                                            if messages.count == 0 {
                                                messages = [message]
                                                if messageRecord == messageRecords!.last {
                                                    completion(success: true, conversation: conversation, messages: messages)
                                                }
                                            } else {
                                                messages += [message]
                                                if messageRecord == messageRecords!.last {
                                                    completion(success: true, conversation: conversation, messages: messages)
                                                }
                                            }
                                        }
                                        
                                    } else {
                                        if messages.count == 0 {
                                            messages = [message]
                                            if messageRecord == messageRecords!.last {
                                                completion(success: true, conversation: conversation, messages: messages)
                                            }
                                        } else {
                                            messages += [message]
                                            if messageRecord == messageRecords!.last {
                                                completion(success: true, conversation: conversation, messages: messages)
                                            }
                                        }
                                    }
                                    
                                })
                            }
                        } else {
                            print("Error")
                        }
                    })
                
            } else {
                completion(success: true, conversation: conversation, messages: [])
            }
        } else {
            completion(success: true, conversation: conversation, messages: [])
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




