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
    
    fileprivate let textKey = "MessageText"
    fileprivate let senderKey = "SenderUID"
    
    var senderUID: CKReference
    var messageText: String
    let ref: CKReference?
    var time:Date?
    var timeString: String?
    var relationship: Relationship?
    var userPic: UIImage?
    

    init(senderUID: CKReference, messageText:String, time: Date?, userPic: UIImage?) {
        self.senderUID = senderUID
        self.messageText = messageText
        self.ref = nil
        if let time = time {
            self.timeString = Timer.sharedInstance.setMessageTime(time)
        }
        self.userPic = userPic
    }
    
    init(record:CKRecord) {
        self.senderUID = record.object(forKey: "SenderUID") as! CKReference
        self.messageText = record.object(forKey: textKey) as? String ?? ""
        self.ref = CKReference(record: record, action: CKReferenceAction.deleteSelf)
//        self.userPic = (record.objectForKey(userPicKey) as? CKAsset)!
    }
    
    func toAnyObject() -> AnyObject {
        return [textKey:messageText,
                senderKey:senderUID] as AnyObject
    }
    
}




