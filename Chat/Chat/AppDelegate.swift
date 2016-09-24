//
//  AppDelegate.swift
//  Chat
//
//  Created by Soren Nelson on 3/29/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var alert: String?
    var alerts: [String?] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            })
            
        } else {
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler:@escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let notificationInfo = userInfo as? [String: NSObject] else { return }
        
        let queryNotification = CKQueryNotification(fromRemoteNotificationDictionary: notificationInfo)
        
        alert = queryNotification.alertBody
        alerts += [alert]
        
//        figure out what to do with these alerts
        
        guard let recordID = queryNotification.recordID else {
            print("No Record ID available from CKQueryNotification.")
            return
        }
        
        let userController = UserController()
        
        userController.fetchRecordWithID(recordID) { (record, error) in
            
            guard let record = record else {
                print("Unable to fetch CKRecord from Record ID")
                return
            }
            
            switch record.recordType {
                
            case "Conversation":
                let convo = Conversation(record: record)
                userController.alerts.append(convo)
            case "Relationship":
                let relationship = Relationship(record: record)
                userController.myRelationship = relationship
            default:
                return
            }
            
        }
        completionHandler(.newData)
    }
    
// TODO: New Notifications
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

