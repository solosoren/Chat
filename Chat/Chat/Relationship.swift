//
//  Relationship.swift
//  Chat
//
//  Created by Soren Nelson on 6/21/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import Foundation
import CloudKit

struct Relationship {
    
    fileprivate let nameKey = "FullName"
    fileprivate let userIDKey = "UserIDRef"
    
    var fullName:String
    var userID: CKReference
    var profilePic: CKAsset?
    var requests: [CKReference]?
    var friends: [CKReference]?
    var myAlertedConversations: [Conversation] = []
    var alerts: [CKReference] = []
    
    init(fullName: String, userID:CKReference, requests: [CKReference]?, friends: [CKReference]?, profilePic: CKAsset?) {
        self.fullName = fullName
        self.userID = userID
        self.requests = requests
        self.friends = friends
        self.profilePic = profilePic
    }
    
    init?(record:CKRecord) {
        fullName = record.object(forKey: nameKey) as? String ?? ""
        userID = (record.object(forKey: userIDKey) as? CKReference)!
        requests = record.object(forKey: "FriendRequests") as? [CKReference] ?? []
        friends = record.object(forKey: "Friends") as? [CKReference] ?? []
        if let profilePic = record.object(forKey: "ImageKey") as? CKAsset {
           self.profilePic = profilePic
        } else {
            self.profilePic = nil
        }        
    }
    
    func toAnyObject() -> Any {
        return [nameKey:fullName,
                userIDKey: userID]
        
    }
    
    
}
