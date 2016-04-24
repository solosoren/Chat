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
    var pFirstName: String?
    var pLastName: String?
    var firstName: String?
    var lastName: String?
    
    init(userID: CKRecordID) {
        self.userID = userID
    }
}
