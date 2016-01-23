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
    private var handle: UInt!
    
    // Firebase REFs
    private var _REF_NOTIFICATIONS = Firebase(url: "\(URL_BASE)/notifications")
    
    var REF_NOTIFICATIONS: Firebase {
        return _REF_NOTIFICATIONS
    }

    var REF_NOTIFICATIONS_USER: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as! String
        return REF_NOTIFICATIONS.childByAppendingPath(uid)
    }
    
    
    // Evented Notification Dictionaries
    
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

    func emit(notificationType: String) -> Bool {
        Event.emit(notificationType)
        return true
    }
    
    init() {
        self.newLoops = [String:String]()
        self.newMessages = [String:String]()
        self.courseActivity = [String:String]()
    }
    
    
    // Notification Data helpers
    
    func getNotifications() {
        handle = REF_NOTIFICATIONS_USER.observeEventType(.Value, withBlock: {
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
                                self.newLoop("A new loop has been created!")
                            } else if type == EVENT_NEW_MESSAGE {
                                self.newMessages[key] = data["loopId"] as? String
                                self.newMessage("You have an unread message!")
                            }
                        }
                    }
                }
            }
        })
    }
    
    func removeNotification(uid: String) {
        REF_NOTIFICATIONS_USER.childByAppendingPath(uid).removeValue()
    }
    
    func removeNotificationObserver() {
        REF_NOTIFICATIONS_USER.removeAuthEventObserverWithHandle(handle!)
    }
    
    
    // MPG Notification objects
    
    func newLoop(message: String) {
        let notification = MPGNotification(title: "New Loop", subtitle: message, backgroundColor: SL_BLACK, iconImage: nil)
        notification.titleColor = SL_WHITE
        notification.subtitleColor = SL_WHITE
        notification.duration = 3
        notification.show()
    }
    
    func newMessage(message: String) {
        let notification = MPGNotification(title: "New Message", subtitle: message, backgroundColor: SL_BLACK, iconImage: nil)
        notification.titleColor = SL_WHITE
        notification.subtitleColor = SL_WHITE
        notification.duration = 3
        notification.show()
    }
    
    func success(message: String) {
        let notification = MPGNotification(title: "Success!", subtitle: message, backgroundColor: SL_WHITE, iconImage: nil)
        notification.titleColor = SL_BLACK
        notification.subtitleColor = SL_BLACK
        notification.duration = 2
        notification.show()
    }
    
    func error() {
        let notification = MPGNotification(title: "Error!", subtitle: "There was a problem :(", backgroundColor: SL_RED, iconImage: nil)
        notification.titleColor = SL_WHITE
        notification.subtitleColor = SL_WHITE
        notification.duration = 2
        notification.show()
    }
    
    
    
    
    // Generic UIAlert

    func showAlert(title: String, msg: String, uiView: UIViewController) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        uiView.presentViewController(alert, animated: true, completion: nil)
    }
}