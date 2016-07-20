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

class Timer {
    
    static let sharedInstance = Timer()
    
    func setMessageTime(record:CKRecord) -> String {
        
        let calendar = NSCalendar.currentCalendar()
        
        let calendarUnit: NSCalendarUnit = [.Day, .Hour, .Minute, .Second]
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let current = NSDate()
        let time = calendar.components(calendarUnit, fromDate: record.creationDate!, toDate: current, options: [])
        
        if calendar.isDateInToday(record.creationDate!) {
            if time.hour < 1 {
                if time.minute < 1 {
                    let dateTime = ("\(time.second) Sec Ago")
                    return dateTime
                } else {
                    let dateTime = ("\(time.minute) Min Ago")
                    return dateTime
                }
            } else if time.hour == 1 {
                let dateTime = ("\(time.hour) Hour Ago")
                return dateTime
            } else {
                let dateTime = ("\(time.hour) Hours Ago")
                return dateTime
            }
        } else {
            if time.day > 1 {
                let dateTime = ("\(time.day) Days Ago")
                return dateTime
            } else {
                let dateTime = ("Yesterday")
                return dateTime
            }
            
        }
    }
}

