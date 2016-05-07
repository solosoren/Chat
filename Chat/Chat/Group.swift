//
//  Group.swift
//  Chat
//
//  Created by Soren Nelson on 5/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import CloudKit

class Group {
    
    private let groupNameKey = "GroupName"
    
    var users: [User]
    var groupName: String?
//    messages?
    
    init(groupName:String, users:[User]) {
        self.groupName = groupName
        self.users = users
    }
    
    init(record:CKRecord) {
        self.groupName = record.objectForKey(groupNameKey) as? String ?? ""
        self.users = record.objectForKey("Users") as! [User]
    }
    
    
    
}
