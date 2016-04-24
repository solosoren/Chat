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
        
    var messages: [Message] = []
    
    static func postMessage(message: Message, completion:(success: Bool) -> Void) {
        let record = CKRecord(recordType: "Message")
        record.setValuesForKeysWithDictionary(message.toAnyObject() as! [String : AnyObject])

        let container = CKContainer.defaultContainer()
        container.publicCloudDatabase.saveRecord(record) { (message, error) in
            if error == nil {
                print(message)
                completion(success: true)
            } else {
                print(error?.localizedDescription)
                completion(success: false)
//                handle error
            }
        }
       
    }
    
    
}
