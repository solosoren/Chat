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
    
    
    init(fullName: String, userID:CKReference) {
        self.fullName = fullName
        self.userID = userID
    }
    
    func toAnyObject() -> AnyObject {
        return [nameKey:fullName,
                userIDKey: userID]
        
    }
    
    
}