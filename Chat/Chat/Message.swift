//
//  Message.swift
//  Chat
//
//  Created by Soren Nelson on 4/17/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

struct Message {
    
    private let textKey = "MessageText"
    
    var senderUID: CKReference
    var messageText: String
    let ref: CKReference?
//    var time: NSDate?
//    var userPic: CKAsset?
    

    init(senderUID: CKReference, messageText:String) {
        self.senderUID = senderUID
        self.messageText = messageText
        self.ref = nil
//        self.time = time
//        self.userPic = userPic
    }
    
    init(record:CKRecord) {
        self.senderUID = (UserController.sharedInstance.myRelationship?.userID)!
        self.messageText = record.objectForKey(textKey) as? String ?? ""
        self.ref = CKReference(record: record, action: CKReferenceAction.DeleteSelf)
//        if record.creationDate != nil {
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.timeStyle = .ShortStyle
//        }
//        self.time = record.creationDate as NSDate!
//        self.userPic = (record.objectForKey(userPicKey) as? CKAsset)!
    }
    
    func toAnyObject() -> AnyObject {
        return [textKey:messageText,
                "SenderUID":senderUID]
    }
    
}




