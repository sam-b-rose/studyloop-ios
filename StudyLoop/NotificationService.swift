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
    private var addedHandle: UInt?
    private var removedHandle: UInt?
    
    private var _notifications: [Notification] {
        willSet(newMessage) {
            self.emit(NOTIFICATION)
        }
    }
    
    // Firebase REFs
    private var _REF_NOTIFICATIONS = Firebase(url: "\(URL_BASE)/notifications")
    
    var REF_NOTIFICATIONS: Firebase {
        return _REF_NOTIFICATIONS
    }
    
    var REF_NOTIFICATIONS_USER: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as! String
        return REF_NOTIFICATIONS.childByAppendingPath(uid)
    }
    
    var notifications: [Notification] {
        return _notifications
    }
    
    // Evented Notification Dictionaries
    
    func emit(notificationType: String) -> Bool {
        Event.emit(notificationType)
        return true
    }
    
    init() {
        self._notifications = [Notification]()
    }
    
    
    // Notification Data helpers
    
    func getNotifications() {
        _notifications.removeAll()
        addedHandle = REF_NOTIFICATIONS_USER.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            if let notiDict = snapshot.value as? Dictionary<String, AnyObject> {
                // Create new Notification object
                let notification = Notification(key: snapshot.key, dictionary: notiDict)
                self._notifications.append(notification)
                self.newNotification(notification)
            }
        })
        
        removedHandle = REF_NOTIFICATIONS_USER.observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            if let index = self._notifications.indexOf({ $0.uid == snapshot.key }) {
                self._notifications.removeAtIndex(index)
            }
        })

    }
    
    func removeNotification(uid: String) {
        print("REMOVING Notificaiton: ", uid)
        REF_NOTIFICATIONS_USER.childByAppendingPath(uid).removeValue()
    }
    
    func removeAllNotifications() {
        REF_NOTIFICATIONS_USER.removeValueWithCompletionBlock {
            error, ref in
            self.success("All notifications have been cleared!")
        }
    }
    
    func removeNotificationObserver() {
        if addedHandle != nil {
            REF_NOTIFICATIONS_USER.removeAuthEventObserverWithHandle(addedHandle!)
        }
    
        if removedHandle != nil {
            REF_NOTIFICATIONS_USER.removeAuthEventObserverWithHandle(removedHandle!)
        }
    }
    
    
    // MPG Notification objects
    
    func newNotification(notification: Notification) {
        var title = "New notification"
        var body = ""
        
        if let loopId = notification.loopId where loopId != "" {
            DataService.ds.REF_LOOPS
                .childByAppendingPath(loopId)
                .childByAppendingPath("subject")
                .observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                    
                    let subject = snapshot.value as! String
                    
                    switch notification.type {
                    case LOOP_MESSAGE_RECEIVED:
                        title = "\(subject)"
                        if let message = notification.textValue where message != "" {
                            body = message
                        }
                        self.showNotification(title, body: body, notificationId: notification.uid)
                        break
                    case LOOP_CREATED:
                        CourseService.cs.REF_COURSES.childByAppendingPath(notification.courseId).observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            
                            if let course = snapshot.value as? Dictionary<String, AnyObject> {
                                title = "\(course["major"]!) \(course["number"]!)"
                            }
                            
                            body = "New loop - \(subject)"
                            self.showNotification(title, body: body, notificationId: notification.uid)
                        })
                        break
                    default:
                        break
                    }
                })
        }
    }
    
    func showNotification(title: String, body: String, notificationId: String) {
        let owl = UIImage(named: "owl-light-square")
        let mpgNotification = MPGNotification(title: title, subtitle: body, backgroundColor: SL_BLACK, iconImage: owl)
        mpgNotification.titleColor = SL_WHITE
        mpgNotification.subtitleColor = SL_WHITE
        mpgNotification.duration = 5
        mpgNotification.setButtonConfiguration(MPGNotificationButtonConfigration.TwoButton, withButtonTitles: ["Dismiss", "Remove"])
        mpgNotification.showWithButtonHandler { (mpgNotification, buttonIndex) -> Void in
            if buttonIndex == mpgNotification.secondButton.tag {
                print("remove the notification")
                self.removeNotification(notificationId)
            }
        }
    }
    
    func success(message: String) {
        let notification = MPGNotification(title: "Success!", subtitle: message, backgroundColor: SL_BLACK, iconImage: nil)
        notification.titleColor = SL_WHITE
        notification.subtitleColor = SL_WHITE
        notification.swipeToDismissEnabled = false
        notification.duration = 3
        notification.show()
    }
    
    func error() {
        let notification = MPGNotification(title: "Error!", subtitle: "There was a problem :(", backgroundColor: SL_RED, iconImage: nil)
        notification.titleColor = SL_WHITE
        notification.subtitleColor = SL_WHITE
        notification.swipeToDismissEnabled = false
        notification.duration = 3
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