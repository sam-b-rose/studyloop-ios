//
//  NotificationService.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/19/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import Firebase
import MPGNotification

class NotificationService {
    static let noti = NotificationService()
    var handle: UInt!
    var newMessages = [String]()
    var newLoops = [String]()
    var courseActivity = [String]()
    
    private var _REF_NOTIFICATIONS = Firebase(url: "\(URL_BASE)/notifications")

    var REF_NOTIFICATIONS: Firebase {
        return _REF_NOTIFICATIONS
    }
    
    var REF_NOTIFICATIONS_USER: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as! String
        return REF_NOTIFICATIONS.childByAppendingPath(uid)
    }
    
    func getNotifications() {
        handle = REF_NOTIFICATIONS_USER.observeEventType(.Value, withBlock: {
            snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let notiDict = snap.value as? Dictionary<String, AnyObject> {
                        // Create Notification Object
                        // Append to Notification Array
                        print(notiDict)
                        if let type = notiDict["type"] as? String, let data = notiDict["data"] as? Dictionary<String, AnyObject> {
                            self.courseActivity.append(data["courseId"] as! String)
                            
                            if type == "LOOP_CREATED" {
                                self.newLoops.append(data["id"] as! String)
                            } else if type == "LOOP MESSAGE_RECEIVED" {
                                self.newMessages.append(data["loopId"] as! String)
                            }
                        }
                    }
                }
            }
        })
    }
    
    func removeNotificationObserver() {
        print("removed notification observer")
        REF_NOTIFICATIONS_USER.removeAuthEventObserverWithHandle(handle!)
    }
    
    func success(message: String) {
        let notification = MPGNotification(title: "Success!", subtitle: message, backgroundColor: SL_WHITE, iconImage: nil)
        notification.titleColor = SL_BLACK
        notification.subtitleColor = SL_BLACK
        notification.swipeToDismissEnabled = false
        notification.duration = 2
        notification.show()
    }
    
    func error() {
        let notification = MPGNotification(title: "Error!", subtitle: "There was a problem :(", backgroundColor: SL_RED, iconImage: nil)
        notification.titleColor = SL_WHITE
        notification.subtitleColor = SL_WHITE
        notification.swipeToDismissEnabled = false
        notification.duration = 2
        notification.show()
    }
}