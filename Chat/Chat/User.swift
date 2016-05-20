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
    
    private let friendsKey = "Friends"
    
    var userID: CKRecordID
    var firstName: String?
    var lastName: String?
    var testArray: [String]?
    var friends: [CKReference]?
    var userPic: CKAsset?
    
    init(userID: CKRecordID) {
        self.userID = userID
    }
    
//    init(record:CKRecord) {
//        self.userID = record.recordID
//        self.friends = record.objectForKey(friendsKey) as? [CKRecordID] ?? []
//    }
    
    
}
