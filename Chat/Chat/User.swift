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
    var firstName: String?
    var lastName: String?
    
    init(userID: CKRecordID) {
        self.userID = userID
    }
    
    
    
//    init(firstName: String, lastName: String, userID: CKRecordID) {
//        self.firstName = firstName
//        self.lastName = lastName
//        self.userID = userID
//    }
    
//    init(user:CKRecord) {
//        self.userID = user.creatorUserRecordID!
//    }
    
//    func toAnyObject() -> AnyObject {
//        return [userID,]
//    }
    
    
}
