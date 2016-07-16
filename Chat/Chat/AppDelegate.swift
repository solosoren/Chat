//
//  AppDelegate.swift
//  Chat
//
//  Created by Soren Nelson on 3/29/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
//        application.registerUserNotificationSettings(notificationSettings)
//        application.registerForRemoteNotifications()
        
        return true
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
//        if cloudKitNotification.notificationType == .Query {
//            let queryNotification = cloudKitNotification as! CKQueryNotification
////            if queryNotification.queryNotificationReason == .RecordDeleted {
////                // If the record has been deleted in CloudKit then delete the local copy here
////            } else {
//            
//                // If the record has been created or changed, we fetch the data from CloudKit
//                let database: CKDatabase
//                if queryNotification.isPublicDatabase {
//                    database = CKContainer.defaultContainer().publicCloudDatabase
//                } else {
//                    database = CKContainer.defaultContainer().privateCloudDatabase
//                }
//                database.fetchRecordWithID(queryNotification.recordID!, completionHandler: { (record: CKRecord?, error: NSError?) -> Void in
//                    guard error == nil else {
//                        // Handle the error here
//                        return
//                    }
//                    
//                    if queryNotification.queryNotificationReason == .RecordUpdated {
//                        // Use the information in the record object to modify your local data
//                    } else {
//                        // Use the information in the record object to create a new local object
//                    }
//                })
////            }
//        }
//    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

