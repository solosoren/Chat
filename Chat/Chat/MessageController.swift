//
//  MessageController.swift
//  Chat
//
//  Created by Soren Nelson on 4/20/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import Foundation
import CloudKit

class MessageController: NSObject {
        
//    var messages: [CKRecord]()
    
    static func postMessage(message: Message, completion:(success: Bool, messageRecord:CKRecord?) -> Void) {
        let record = CKRecord(recordType: "Message")
        record.setValuesForKeysWithDictionary(message.toAnyObject() as! [String : AnyObject])

        let container = CKContainer.defaultContainer()
        container.publicCloudDatabase.saveRecord(record) { (message, error) in
            if error == nil {
                completion(success: true, messageRecord: message)
            } else {
                print(error?.localizedDescription)
                completion(success: false, messageRecord: nil)
//                handle error
            }
        }
       
    }
    
    static func fetchConversationMessages(completion:(success: Bool) -> Void) {
        
    }
    
    
}
