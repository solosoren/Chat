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
    var time: String?
    var relationship: Relationship?
    var userPic: UIImage?
    

    init(senderUID: CKReference, messageText:String, time: NSDate?, userPic: UIImage?) {
        self.senderUID = senderUID
        self.messageText = messageText
        self.ref = nil
        if let time = time {
            self.time = Timer.sharedInstance.setMessageTime(time)
        }
        self.userPic = userPic
    }
    
    init(record:CKRecord) {
        self.senderUID = record.objectForKey("SenderUID") as! CKReference
        self.messageText = record.objectForKey(textKey) as? String ?? ""
        self.ref = CKReference(record: record, action: CKReferenceAction.DeleteSelf)
//        self.userPic = (record.objectForKey(userPicKey) as? CKAsset)!
    }
    
    func toAnyObject() -> AnyObject {
        return [textKey:messageText,
                "SenderUID":senderUID]
    }
    
}




