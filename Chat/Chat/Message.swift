//
//  Message.swift
//  Chat
//
//  Created by Soren Nelson on 4/17/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

class Message {
    
    private let senderUIDKey = "SenderUID"
    private let textKey = "MessageText"
    private let userPicKey = "UserPic"
    
    var senderUID: String
    var messageText: String
//    var time: NSDate?
//    var userPic: CKAsset?
    
    init(senderUID: String, messageText:String) {
        self.senderUID = senderUID
        self.messageText = messageText
//        self.time = time
//        self.userPic = userPic
    }
    
//    set user to created by identifier
    init(record:CKRecord) {
        self.senderUID = record.objectForKey(senderUIDKey) as? String ?? ""
        self.messageText = record.objectForKey(textKey) as? String ?? ""
//        if record.creationDate != nil {
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.timeStyle = .ShortStyle
//        }
//        self.time = record.creationDate as NSDate!
//        self.userPic = (record.objectForKey(userPicKey) as? CKAsset)!
    }
    
    func toAnyObject() -> AnyObject {
        return [textKey:messageText]
    }
    
}




