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
    
    static func createConversation(_ conversation:Conversation, completion:@escaping (_ success:Bool, _ record: CKRecord?) -> Void) {
        let record = CKRecord(recordType: "Conversation")
        record.setValuesForKeys(conversation.toAnyObject() as! [String : AnyObject])
//        record.setObject([], "Messages")
        let container = CKContainer.default()
        container.publicCloudDatabase.save(record, completionHandler: { (conversation, error) in
            if error == nil {
                completion(true, record)

            } else {
                print("error: \(error?.localizedDescription)")
                completion(false, nil)
//                handle error
            }
            
        }) 
    }
    
    func grabUserConversations(_ relationship:Relationship, completion:@escaping (_ success:Bool, _ conversations:[Conversation]?, _ convoRecords:[CKRecord]?) -> Void) {
        
        var convoNumber = 0
        var conversations: [Conversation] = []
        let container = CKContainer.default()
        let pred = NSPredicate(format: "Users CONTAINS %@", relationship.userID)
        let query = CKQuery(recordType: "Conversation", predicate: pred)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

        container.publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                if records?.count != 0 {
                    
                    for record in records! {
                        var conversation = Conversation(record: record)
                        conversation.ref = record.recordID

                        conversation.convoName = record["GroupName"] as! String?
                        self.subscribeToConversations(record, contentAvailable: true, alertBody: "You have a new message", completion: { (success) in
                            if conversation.messages?.count != 0 {
                                let ref = conversation.messages?.last
                                UserController.sharedInstance.fetchAlerts(messageRef: ref!)
                                container.publicCloudDatabase.fetch(withRecordID: (ref?.recordID)!, completionHandler: { (lastMessageRecord, error) in
                                    if error == nil {
                                        conversation.lastMessage = Message(record: lastMessageRecord!)
                                        UserController.sharedInstance.grabImageByUID((conversation.lastMessage?.senderUID.recordID)!, completion: { (success, image) in
                                            if success {
                                                convoNumber = convoNumber + 1
                                                conversation.lastMessage?.userPic = image
                                                conversation.lastMessage?.time = lastMessageRecord?.creationDate
                                                conversation.lastMessage?.timeString = Timer.sharedInstance.setMessageTime(lastMessageRecord!.creationDate!)
                                                conversations += [conversation]
                                                if convoNumber == records?.count {
                                                    completion(true, conversations, records)
                                                }
                                            } else {
                                                convoNumber = convoNumber + 1
                                                conversation.lastMessage?.time = lastMessageRecord?.creationDate
                                                conversation.lastMessage?.timeString = Timer.sharedInstance.setMessageTime(lastMessageRecord!.creationDate!)
                                                conversations += [conversation]
                                                if convoNumber == records?.count {
                                                    completion(true, conversations, records)
                                                }
                                            }
                                        })
                                    } else {
                                        print(error)
                                        convoNumber = convoNumber + 1
                                        conversations += [conversation]
                                        if convoNumber == records?.count {
                                            completion(true, conversations, records)
                                        }
                                    }
                                })
                            } else {
                                convoNumber = convoNumber + 1
                                conversations += [conversation]
                                if convoNumber == records?.count {
                                    completion(true, conversations, records)
                                }
                            }
                        })
                    }
                } else {
                    completion(true, [], [])
                }
            } else {
                print("ERROR: \(error?.localizedDescription)")
                completion(true, [], [])
            }
        }
    }
    
    func grabMessages(_ conversation:Conversation, completion:((_ error: NSError?, _ conversation: Conversation?, _ messages:[Message]?) -> Void)?) {
        
        var refNumber = 0
        var records:[CKRecord] = []
        let container = CKContainer.default()
        var messages: [Message] = []
        if let messageRefs: [CKReference] = conversation.messages {
            if messageRefs.count != 0 {
                print("CONVERSATION HAS \(conversation.messages!.count) MESSAGES")
                for ref in messageRefs {
                    container.publicCloudDatabase.fetch(withRecordID: ref.recordID, completionHandler: { (record, error) in
                        
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
                        message.timeString = time
                        message.time = record.creationDate
                        
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
                                    
                                    let sorted = records.sorted(by: {$0.0.creationDate?.compare($0.1.creationDate!) == ComparisonResult.orderedAscending})
                                    var sortedMessages:[Message] = []
                                    var convo = conversation
                                    convo.messages = []
                                    for r in sorted {
                                        for m in messages {
                                            let ref = CKReference(record: r, action: .deleteSelf)
                                            if ref == m.ref {
                                                sortedMessages.append(m)
                                                convo.messages?.append(ref)
                                            }
                                        }
                                    }
                                    if let completion = completion {
                                        completion(error as NSError?, convo, sortedMessages)
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
                                    let sorted = records.sorted(by: {$0.0.creationDate?.compare($0.1.creationDate!) == ComparisonResult.orderedAscending})
                                    var sortedMessages:[Message] = []
                                    var convo = conversation
                                    convo.messages = []
                                    for r in sorted {
                                        for m in messages {
                                            let ref = CKReference(record: r, action: .deleteSelf)
                                            if ref == m.ref {
                                                sortedMessages.append(m)
                                                convo.messages?.append(ref)
                                            }
                                        }
                                    }
                                    if let completion = completion {
                                        completion(error as NSError?, conversation, messages)
                                    }
                                }
                            }
                        })
                    })
                }
            } else {
                if let completion = completion {
                    completion(nil, conversation, [])
                }
            }
        } else {
            if let completion = completion {
                completion(nil, conversation, [])
            }
        }
    }
    
 
    
    func subscribeToConversations(_ conversationRecord:CKRecord, contentAvailable:Bool, alertBody:String? = nil, completion:@escaping (_ success:Bool) -> Void) {
        
        let pred = NSPredicate(format: "Users CONTAINS %@", UserController.sharedInstance.myRelationship!.userID)
        let sub = CKSubscription(recordType: "Conversation", predicate: pred, subscriptionID: "\(conversationRecord.recordID)A", options: [.firesOnRecordUpdate, .firesOnRecordCreation])

        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        notificationInfo.shouldSendContentAvailable = contentAvailable
        sub.notificationInfo = notificationInfo
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.save(sub, completionHandler: { (subscription, error) in
            if subscription != nil {
                completion(true)
            } else {
//                FIX
                NSLog("ERROR: \(error)")
                completion(true)
            }
        }) 
        
    }
    
    func subscribe(_ type: String, predicate: NSPredicate, subscriptionID: String, contentAvailable: Bool, alertBody: String? = nil, desiredKeys: [String]? = nil, options: CKSubscriptionOptions, completion: ((_ subscription: CKSubscription?, _ error: NSError?) -> Void)?) {
        
        let subscription = CKSubscription(recordType: type, predicate: predicate, subscriptionID: subscriptionID, options: options)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        notificationInfo.shouldSendContentAvailable = contentAvailable
        notificationInfo.desiredKeys = desiredKeys
        
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().publicCloudDatabase.save(subscription, completionHandler: { (subscription, error) in
            
            if let completion = completion {
                completion(subscription, error as NSError?)
            }
        }) 
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
    
    
//    func fetchNotificationChanges(completion:(success:Bool) -> Void) {
//        let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: nil)
//        
//        var notificationIDsToMarkRead = [CKNotificationID]()
//        
//        operation.notificationChangedBlock = { (notification: CKNotification) -> Void in
//// Process each notification received
//            if notification.notificationType == .Query {
//                let queryNotification = notification as! CKQueryNotification
//                let reason = queryNotification.queryNotificationReason
//                let recordID = queryNotification.recordID
//                
////                print("reason \(reason)")
//                print("recordID \(recordID)")
//                
//                let ref = CKReference(recordID: recordID!, action: .DeleteSelf)
//                UserController.sharedInstance.myRelationship!.alerts.append(ref)
//                
//                // Add the notification id to the array of processed notifications to mark them as read
//                notificationIDsToMarkRead.append(queryNotification.notificationID!)
//                if operation.moreComing == false  {
//                    completion(success: true)
//                }
//            }
//        }
    
//        operation.fetchNotificationChangesCompletionBlock = { (serverChangeToken: CKServerChangeToken?, operationError: NSError?) -> Void in
//            guard operationError == nil else {
//                // Handle the error here
//                return
//            }
//            
//            // Mark the notifications as read to avoid processing them again
//            let markOperation = CKMarkNotificationsReadOperation(notificationIDsToMarkRead: notificationIDsToMarkRead)
//            markOperation.markNotificationsReadCompletionBlock = { (notificationIDsMarkedRead: [CKNotificationID]?, operationError: NSError?) -> Void in
//                guard operationError == nil else {
//                    // Handle the error here
//                    return
//                }
//            }
//            
//            let operationQueue = NSOperationQueue()
//            operationQueue.addOperation(markOperation)
//        }
//        
//        let operationQueue = NSOperationQueue()
//        operationQueue.addOperation(operation)
//    }

}




