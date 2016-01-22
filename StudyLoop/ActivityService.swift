//
//  ActivityService.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/20/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class ActivityService {
    
    static let act = ActivityService()
    
    private var _REF_ACTIVITY = Firebase(url: "\(URL_BASE)/user-activity")
    private var _REF_LOOP = Firebase(url: "\(URL_BASE)/user-activity/loops")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/user-activity/users")
    
    var REF_ACTIVITY: Firebase {
        return _REF_ACTIVITY
    }
    
    var REF_LOOP: Firebase {
        return _REF_LOOP
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: Firebase {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        let loopId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_LOOP) as? String
        return REF_LOOP.childByAppendingPath(loopId).childByAppendingPath(userId)
    }
    
    func setUserActivity(loopId: String, userId: String, key: String, value: AnyObject) {
        REF_LOOP.childByAppendingPath(loopId)
            .childByAppendingPath(userId)
            .childByAppendingPath(key)
            .setValue(value)
    }
    
    func setLastLoop(loopId: String) {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        REF_USERS.childByAppendingPath(userId).childByAppendingPath("loopId").setValue(loopId)
    }
   
    func getLastCourse(completion: (result: String) -> Void) {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        REF_USERS.childByAppendingPath(userId).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let userActivityDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let courseId = userActivityDict["courseId"] as? String {
                    completion(result: courseId)
                }
            }
        })
    }
    
    func setLastCourse(courseId: String) {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        REF_USERS.childByAppendingPath(userId).childByAppendingPath("courseId").setValue(courseId)
    }
}