//
//  Conversation.swift
//  Chat
//
//  Created by Soren Nelson on 7/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import CloudKit
import UIKit

struct Conversation {
    
    private let groupNameKey = "GroupName"
    private let usersKey = "Users"
    private let messagesKey = "Messages"
    
    var ref: CKRecordID?
    var users: [CKReference]
    var convoName: String?
    var messages: [CKReference]?
    var lastMessage: Message?
    var theMessages: [Message] = []
    
    init(convoName:String?, users:[CKReference], messages: [CKReference]?) {
        self.convoName = convoName
        self.users = users
        self.messages = messages
    }
    
    init(record:CKRecord) {
        self.convoName = record.objectForKey(groupNameKey) as? String ?? ""
        self.users = record.objectForKey(usersKey) as! [CKReference]
        self.messages = record.objectForKey(messagesKey) as? [CKReference] ?? []
    }
    
    func toAnyObject() -> AnyObject {
        
        if let groupName = convoName {
            return [groupNameKey:groupName,
                    usersKey:users]
        } else {
            return [usersKey:users]
        }
             
    }
    
    
    
}



