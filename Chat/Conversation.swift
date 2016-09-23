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
    
    fileprivate let groupNameKey = "GroupName"
    fileprivate let usersKey = "Users"
    fileprivate let messagesKey = "Messages"
    
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
        self.convoName = record.object(forKey: groupNameKey) as? String ?? ""
        self.users = record.object(forKey: usersKey) as! [CKReference]
        self.messages = record.object(forKey: messagesKey) as? [CKReference] ?? []
    }
    
    func toAnyObject() -> Any {
        
        if let groupName = convoName {
            let convo = [groupNameKey:groupName,
                    usersKey:users] as Any
            return convo
        } else {
            let convo = [usersKey:users]
            return convo
        }
             
    }
    
    
    
}



