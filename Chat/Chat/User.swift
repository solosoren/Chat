//
//  User.swift
//  Chat
//
//  Created by Soren Nelson on 4/20/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    var userID: CKRecordID
    var fullName: String?
    var friends: [CKReference]?
    var userPic: CKAsset?
    
    init(userID: CKRecordID, fullName: String?, friends:[CKReference]?, userPic: CKAsset?) {
        self.userID = userID
        self.fullName = fullName
    }
    
//    init(record:CKRecord) {
//        self.userID = record.recordID
//        self.friends = record.objectForKey(friendsKey) as? [CKReference] ?? []
//    }
    
    
}
