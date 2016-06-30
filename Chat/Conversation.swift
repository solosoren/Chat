//
//  Conversation.swift
//  Chat
//
//  Created by Soren Nelson on 5/7/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import CloudKit
import UIKit

struct Conversation {
    
    private let groupNameKey = "GroupName"
    private let usersKey = "Users"
    private let messagesKey = "Messages"
    
    let ref: CKReference?
    var users: [CKReference]
    var convoName: String?
    var messages: [CKReference]?
    
//    init(convoName:String?, users:[CKReference], messages: [CKReference]?) {
    init(convoName:String?, users:[CKReference]) {
        self.convoName = convoName
        self.users = users
        self.ref = nil
    }
    
    init(record:CKRecord) {
        self.convoName = record.objectForKey(groupNameKey) as? String ?? ""
        self.users = record.objectForKey(usersKey) as! [CKReference]
        self.messages = record.objectForKey(messagesKey) as? [CKReference] ?? []
        self.ref = CKReference(record: record, action: CKReferenceAction.DeleteSelf)
    }
    
    func toAnyObject() -> AnyObject {
        
        if let groupName = convoName {
            return [groupNameKey:groupName,
                    usersKey:users]
        } else {
            return [usersKey:users]
        }
        
//        if let groupName = convoName {
//            if let messages = messages {
//                return [groupNameKey:groupName,
//                        usersKey:users,
//                        messagesKey:messages]
//            } else {
//                return [groupNameKey: groupName,
//                        usersKey: users,
//                        messagesKey: []]
//            }
//        } else {
//            if let messages = messages {
//                return [groupNameKey:"",
//                        usersKey:users,
//                        messagesKey:messages]
//            } else {
//                return [groupNameKey: "",
//                        usersKey:users,
//                        messagesKey: []]
//            }
//
//        }
//        
    }
    
    
    
}
