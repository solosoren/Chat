//
//  ConversationController.swift
//  Chat
//
//  Created by Soren Nelson on 5/10/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import CloudKit

class ConversationController: NSObject {
    
    static func createConversation(conversation:Conversation, completion:(success:Bool) -> Void) {
        let record = CKRecord(recordType: "Conversation")
        record.setValuesForKeysWithDictionary(conversation.toAnyObject() as! [String : AnyObject])
        
        let container = CKContainer.defaultContainer()
        container.publicCloudDatabase.saveRecord(record) { (conversation, error) in
            if error == nil {
                completion(success: true)
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
                for record in records! {
                    var conversation = Conversation(convoName: record["GroupName"] as? String, users: record["Users"] as! [CKReference], messages: record["Messages"] as? [CKReference])
                    
                    let lastRecord = CKRecord(recordType: "Message", recordID: (conversation.messages?.last?.recordID)!)
                    let message = Message(senderUID: lastRecord.creatorUserRecordID!, messageText: lastRecord["MessageText"] as! String)
                    conversation.lastMessage = message
                    
                    conversations += [conversation]
                }
                completion(success: true, conversations: conversations)
            } else {
                print("ERROR: \(error?.localizedDescription)")
                completion(success: false, conversations: nil)
            }
        }
    }
    
}








