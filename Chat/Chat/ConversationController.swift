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
        
        var convoNumber = 0
        var conversations: [Conversation] = []
        let container = CKContainer.defaultContainer()
        let pred = NSPredicate(format: "Users CONTAINS %@", relationship.userID)
        let query = CKQuery(recordType: "Conversation", predicate: pred)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

        container.publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (records, error) in
            if error == nil {
                if records?.count != 0 {
                    
                    for record in records! {
                        var conversation = Conversation(record: record)
                        conversation.ref = record.recordID
//                        if let myName = UserController.sharedInstance.myRelationship?.fullName {
//                            if let range = groupName?.rangeOfString("\(myName), ") {
//                                groupName?.removeRange(range)
//                                
//                            }
//                            if let range = groupName?.rangeOfString(", \(myName)") {
//                                groupName?.removeRange(range)
//                            }
                        //                        }
                        conversation.convoName = record["GroupName"] as! String?
                        self.subscribeToConversations(record, contentAvailable: true, alertBody: "You have a new message", completion: { (success) in
                            if conversation.messages?.count != 0 {
                                let ref = conversation.messages?.last
                                container.publicCloudDatabase.fetchRecordWithID((ref?.recordID)!, completionHandler: { (lastMessageRecord, error) in
                                    if error == nil {
                                        conversation.lastMessage = Message(record: lastMessageRecord!)
                                        UserController.sharedInstance.grabImageByUID((conversation.lastMessage?.senderUID.recordID)!, completion: { (success, image) in
                                            if success {
                                                convoNumber = convoNumber + 1
                                                conversation.lastMessage?.userPic = image
                                                conversation.lastMessage?.time = Timer.sharedInstance.setMessageTime(lastMessageRecord!.creationDate!)
                                                conversations += [conversation]
                                                if convoNumber == records?.count {
                                                    completion(success: true, conversations: conversations, convoRecords: records)
                                                }
                                            } else {
                                                convoNumber = convoNumber + 1
                                                conversation.lastMessage?.time = Timer.sharedInstance.setMessageTime(lastMessageRecord!.creationDate!)
                                                conversations += [conversation]
                                                if convoNumber == records?.count {
                                                    completion(success: true, conversations: conversations, convoRecords: records)
                                                }
                                            }
                                        })
                                    } else {
                                        print(error)
                                        convoNumber = convoNumber + 1
                                        conversations += [conversation]
                                        if convoNumber == records?.count {
                                            completion(success: true, conversations: conversations, convoRecords: records)
                                        }
                                    }
                                })
                            } else {
                                convoNumber = convoNumber + 1
                                conversations += [conversation]
                                if convoNumber == records?.count {
                                    completion(success: true, conversations: conversations, convoRecords: records)
                                }
                            }
                        })
                    }
                } else {
                    completion(success: true, conversations: [], convoRecords: [])
                }
            } else {
                print("ERROR: \(error?.localizedDescription)")
                completion(success: true, conversations: [], convoRecords: [])
            }
        }
    }
    
    func grabMessages(conversation:Conversation, completion:((error: NSError?, conversation: Conversation?, messages:[Message]?) -> Void)?) {
        
        var refNumber = 0
        var records:[CKRecord] = []
        let container = CKContainer.defaultContainer()
        var messages: [Message] = []
        if let messageRefs: [CKReference] = conversation.messages {
            if messageRefs.count != 0 {
                print("CONVERSATION HAS \(conversation.messages!.count) MESSAGES")
                for ref in messageRefs {
                    container.publicCloudDatabase.fetchRecordWithID(ref.recordID, completionHandler: { (record, error) in
                        
                        guard let record = record else {
                            if let error = error {
                                print(error)
                            }
                            return
                        }
                        records.append(record)
                        let time = Timer.sharedInstance.setMessageTime(record.creationDate!)
                        var message = Message(record: record)
                        print("MESSAGE: \(message)")
                        message.time = time
                        
                        UserController.sharedInstance.grabImageByUID(message.senderUID.recordID, completion: { (success, image) in
                            if success {
                                refNumber = refNumber + 1
                                print("REF NUMBER: \(refNumber)")
                                if image != nil {
                                    message.userPic = image
                                    if messages.count == 0 {
                                        messages = [message]
                                    } else {
                                        messages += [message]
                                    }
                                } else {
                                    message.userPic = nil
                                    if messages.count == 0 {
                                        messages = [message]
                                    } else {
                                        messages += [message]
                                    }
                                }
                                if refNumber == messageRefs.count {
                                    
                                    let sorted = records.sort({$0.0.creationDate?.compare($0.1.creationDate!) == NSComparisonResult.OrderedAscending})
                                    var sortedMessages:[Message] = []
                                    var convo = conversation
                                    convo.messages = []
                                    for r in sorted {
                                        for m in messages {
                                            let ref = CKReference(record: r, action: .DeleteSelf)
                                            if ref == m.ref {
                                                sortedMessages.append(m)
                                                convo.messages?.append(ref)
                                            }
                                        }
                                    }
                                    if let completion = completion {
                                        completion(error: error, conversation: convo, messages: sortedMessages)
                                    }
                                }
                                
                            } else {
                                refNumber = refNumber + 1
                                print("REF NUMBER: \(refNumber)")
                                message.userPic = nil
                                if messages.count == 0 {
                                    messages = [message]
                                } else {
                                    messages += [message]
                                }
                                if refNumber == messageRefs.count {
                                    let sorted = records.sort({$0.0.creationDate?.compare($0.1.creationDate!) == NSComparisonResult.OrderedAscending})
                                    var sortedMessages:[Message] = []
                                    var convo = conversation
                                    convo.messages = []
                                    for r in sorted {
                                        for m in messages {
                                            let ref = CKReference(record: r, action: .DeleteSelf)
                                            if ref == m.ref {
                                                sortedMessages.append(m)
                                                convo.messages?.append(ref)
                                            }
                                        }
                                    }
                                    if let completion = completion {
                                        completion(error: error, conversation: conversation, messages: messages)
                                    }
                                }
                            }
                        })
                    })
                }
            } else {
                if let completion = completion {
                    completion(error: nil, conversation: conversation, messages: [])
                }
            }
        } else {
            if let completion = completion {
                completion(error: nil, conversation: conversation, messages: [])
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
    
//    func fetchSubscription(subscriptionID: String, completion: ((subscription: CKSubscription?, error: NSError?) -> Void)?) {
//        CKContainer.defaultContainer().publicCloudDatabase.fetchSubscriptionWithID(subscriptionID) { (subscription, error) in
//            if let completion = completion {
//                completion(subscription: subscription, error: error)
//            }
//        }
//    }
    
//    func checksubscriptionToConversation(conversationRecord:CKRecord, completion:((subscribed:Bool) -> Void)?) {
//        fetchSubscription(("\(conversationRecord.recordID)A")) { (subscription, error) in
//            if let completion = completion {
//                let subscribed = subscription != nil
//                completion(subscribed: subscribed)
//            }
//        }
//    }
    
//    func unsubscribeFromConversation(subscriptionID: String, completion:((subscriptionID: String?, error:NSError?) -> Void)?) {
//        CKContainer.defaultContainer().publicCloudDatabase.deleteSubscriptionWithID(subscriptionID) { (subscriptionID, error) in
//            
//            if let completion = completion {
//                completion(subscriptionID: subscriptionID, error: error)
//            }
//        }
//    }
    
//    call when delete row?
//    maybe in info button
//    func removeSubscriptionFromConversation(conversationRecord:CKRecord, completion:((success:Bool, error:NSError?) -> Void)?) {
//        unsubscribeFromConversation(("\(conversationRecord.recordID)A")) { (subscriptionID, error) in
//            if let completion = completion {
//                let success = subscriptionID != nil
//                completion(success: success, error: error)
//            }
//        }
//    }
    
    
    func fetchNotificationChanges() {
        let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: nil)
        
        var notificationIDsToMarkRead = [CKNotificationID]()
        
        operation.notificationChangedBlock = { (notification: CKNotification) -> Void in
            // Process each notification received
            if notification.notificationType == .Query {
                let queryNotification = notification as! CKQueryNotification
                let reason = queryNotification.queryNotificationReason
                let recordID = queryNotification.recordID
                
                print("reason \(reason)")
                print("recordID \(recordID)")
                
                let ref = CKReference(recordID: recordID!, action: .DeleteSelf)
                UserController.sharedInstance.myRelationship!.alerts.append(ref)
                // Add the notification id to the array of processed notifications to mark them as read
                notificationIDsToMarkRead.append(queryNotification.notificationID!)
            }
        }
        
        operation.fetchNotificationChangesCompletionBlock = { (serverChangeToken: CKServerChangeToken?, operationError: NSError?) -> Void in
            guard operationError == nil else {
                // Handle the error here
                return
            }
            
            // Mark the notifications as read to avoid processing them again
            let markOperation = CKMarkNotificationsReadOperation(notificationIDsToMarkRead: notificationIDsToMarkRead)
            markOperation.markNotificationsReadCompletionBlock = { (notificationIDsMarkedRead: [CKNotificationID]?, operationError: NSError?) -> Void in
                guard operationError == nil else {
                    // Handle the error here
                    return
                }
            }
            
            let operationQueue = NSOperationQueue()
            operationQueue.addOperation(markOperation)
        }
        
        let operationQueue = NSOperationQueue()
        operationQueue.addOperation(operation)
    }

}




