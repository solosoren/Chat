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
    
    private let nameKey = "FullName"
    private let userIDKey = "UserIDRef"
    
    var fullName:String
    var userID: CKReference
    var profilePic: CKAsset?
    var requests: [CKReference]?
    var friends: [CKReference]?
    
    init(fullName: String, userID:CKReference, requests: [CKReference]?, friends: [CKReference]?, profilePic: CKAsset?) {
        self.fullName = fullName
        self.userID = userID
        self.requests = requests
        self.friends = friends
        self.profilePic = profilePic
    }
    
    init?(record:CKRecord) {
        fullName = record.objectForKey(nameKey) as? String ?? ""
        userID = (record.objectForKey(userIDKey) as? CKReference)!
        requests = record.objectForKey("FriendRequests") as? [CKReference] ?? []
        friends = record.objectForKey("Friends") as? [CKReference] ?? []
        guard let profilePic = record.objectForKey("ImageKey") as? CKAsset else { return nil }
        self.profilePic = profilePic
    }
    
    func toAnyObject() -> AnyObject {
        return [nameKey:fullName,
                userIDKey: userID]
        
    }
    
    
}