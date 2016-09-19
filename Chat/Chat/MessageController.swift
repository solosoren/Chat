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
    
    static func postMessage(_ message: Message, completion:@escaping (_ success: Bool, _ messageRecord:CKRecord?) -> Void) {
        let record = CKRecord(recordType: "Message")
        record.setValuesForKeys(message.toAnyObject() as! [String : AnyObject])
        
        let container = CKContainer.default()
        container.publicCloudDatabase.save(record, completionHandler: { (message, error) in
            if error == nil {
                completion(true, message)
            } else {
                print(error?.localizedDescription)
                completion(false, nil)
//                handle error
            }
        }) 
       
    }
    
    static func fetchConversationMessages(_ completion:(_ success: Bool) -> Void) {
        
    }
    
    
}

class Timer {
    
    static let sharedInstance = Timer()
    
    func setMessageTime(_ date:Date) -> String {
        
        let calendar = Calendar.current
        
        let calendarUnit: NSCalendar.Unit = [.day, .hour, .minute, .second]
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let current = Date()
        let time = (calendar as NSCalendar).components(calendarUnit, from: date, to: current, options: [])
        
        if calendar.isDateInToday(date) {
            if time.hour! < 1 {
                if time.minute! < 1 {
                    let dateTime = ("\((time.second)!) Sec Ago")
                    return dateTime
                } else {
                    let dateTime = ("\((time.minute)!) Min Ago")
                    return dateTime
                }
            } else if time.hour == 1 {
                let dateTime = ("\((time.hour)!) Hour Ago")
                return dateTime
            } else {
                let dateTime = ("\((time.hour)!) Hours Ago")
                return dateTime
            }
        } else {
            if time.day! > 1 {
                let dateTime = ("\((time.day)!) Days Ago")
                return dateTime
            } else {
                let dateTime = ("Yesterday")
                return dateTime
            }
            
        }
    }
}

