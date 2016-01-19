//
//  NotificationService.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/19/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import MPGNotification

class NotificationService {
    static let noti = NotificationService()
    
    func success(message: String) {
        let notification = MPGNotification(title: "Success!", subtitle: message, backgroundColor: SL_LIGHT, iconImage: nil)
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