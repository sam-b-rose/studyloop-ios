//
//  InitialVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 2/6/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import Firebase

class InitialVC: UIViewController {
    
    var authRef: Firebase!
    var deviceRef: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authRef = DataService.ds.REF_BASE
        deviceRef = DataService.ds.REF_QUEUES.childByAppendingPath("user-devices").childByAppendingPath("tasks")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // Check if user is already authenticated
        authRef.observeAuthEventWithBlock({
            authData in
            if authData != nil {
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                self.saveDeviceId(authData.uid)
                UserService.us.watchCurrentUser({ (result) -> Void in
                    UserService.us.updateProfilePicture(authData.providerData["profileImageURL"])
                    self.checkUserData(authData)
                })
            } else {
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
                self.performSegueWithIdentifier(SEGUE_LOGGED_OUT, sender: nil)
            }
        })
    }
    
    func saveDeviceId(userId: String) {
        if let deviceId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_DEVICE_ID) as? String {
            deviceRef.childByAutoId().setValue([
                "createdAt": kFirebaseServerValueTimestamp,
                "updatedAt": kFirebaseServerValueTimestamp,
                "userId": userId,
                "vendor": "ios",
                "vendorId": deviceId
                ])
        }
    }
    
    // TODO: Fix Segues
    
    func checkUserData(authData: FAuthData) {
        if UserService.us.currentUser.universityId == nil {
            self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
        } else {
            if let tempPassword = authData.providerData["isTemporaryPassword"] as? Int where tempPassword == 1 {
                // change password
                self.performSegueWithIdentifier(SEGUE_CHANGE_PWD, sender: nil)
            } else {
                // Get last course
                ActivityService.act.getLastCourse({ (courseId) -> Void in
                    NSUserDefaults.standardUserDefaults().setValue(courseId, forKey: KEY_COURSE)
                    NotificationService.noti.getNotifications()
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                })
            }
        }
    }
}
