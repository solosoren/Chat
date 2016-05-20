//
//  ConversationController.swift
//  Chat
//
//  Created by Soren Nelson on 5/10/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import CloudKit

class ConversationController: NSObject {
    
    
    static func createConversation(conversation:Conversation, completion:(success:Bool) -> Void) {
        let record = CKRecord(recordType: "Conversation")
        record.setValuesForKeysWithDictionary(conversation.toAnyObject() as! [String : AnyObject])
        
        let container = CKContainer.defaultContainer()
        container.publicCloudDatabase.saveRecord(record) { (conversation, error) in
            if error == nil {
                completion(success: true)
            } else {
                print("error: \(error?.localizedDescription)")
                completion(success: false)
                //                handle error
            }
            
        }
    }
    
}
