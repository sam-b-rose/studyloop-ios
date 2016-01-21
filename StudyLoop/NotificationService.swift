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

protocol Evented {
    func emit(message: String) -> Bool
}

class NotificationService: Evented {
    
    static let noti = NotificationService()
    private var _REF_NOTIFICATIONS = Firebase(url: "\(URL_BASE)/notifications")
    
    var REF_NOTIFICATIONS: Firebase {
        return _REF_NOTIFICATIONS
    }
    
    private var _handle: UInt!
    
    var courseActivity: [String:String] {
        willSet(newCourse) {
            self.emit(EVENT_COURSE_ALERT)
        }
    }
    
    var newMessages: [String:String] {
        willSet(newMessage) {
            self.emit(EVENT_NEW_MESSAGE)
        }
    }
    
    var newLoops: [String:String] {
        willSet(newLoop) {
            self.emit(EVENT_NEW_LOOP)
        }
    }
    
    var REF_NOTIFICATIONS_USER: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as! String
        return REF_NOTIFICATIONS.childByAppendingPath(uid)
    }
    
    init() {
        self.newLoops = [String:String]()
        self.newMessages = [String:String]()
        self.courseActivity = [String:String]()
    }
    
    func getNotifications() {
        _handle = REF_NOTIFICATIONS_USER.observeEventType(.Value, withBlock: {
            snapshot in
            
            self.courseActivity.removeAll()
            self.newMessages.removeAll()
            self.newLoops.removeAll()
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let notiDict = snap.value as? Dictionary<String, AnyObject> {
                        // Append to Notification Array
                        print(notiDict)
                        
                        if let type = notiDict["type"] as? String, let data = notiDict["data"] as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            self.courseActivity[key] = data["courseId"] as? String
                            
                            if type == EVENT_NEW_LOOP {
                                self.newLoops[key] = data["id"] as? String
                            } else if type == EVENT_NEW_MESSAGE {
                                self.newMessages[key] = data["loopId"] as? String
                            }
                        }
                    }
                }
            }
        })
    }
    
    func removeNotification(uid: String) {
//        switch type {
//        case "LOOP_MESSAGE_RECEIVED":
//            newMessages.removeValueForKey(uid)
//            break
//        case "LOOP_CREATED":
//            newLoops.removeValueForKey(uid)
//            break
//        default:
//            break
//        }
//        courseActivity.removeValueForKey(uid)
        print("Removing Notification", uid)
        REF_NOTIFICATIONS_USER.childByAppendingPath(uid).removeValue()
    }
    
    func removeNotificationObserver() {
        REF_NOTIFICATIONS_USER.removeAuthEventObserverWithHandle(_handle!)
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
    
    func emit(notificationType: String) -> Bool {
        notificationType.log_debug()
        Event.emit(notificationType)
        return true
    }
}