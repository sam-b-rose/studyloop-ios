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
    
    var REF_ACTIVITY: Firebase {
        return _REF_ACTIVITY
    }
    
    var REF_LOOP: Firebase {
        return _REF_LOOP
    }
    
    func setUserActivity(loopId: String, userId: String, key: String, value: AnyObject) {
        REF_LOOP.childByAppendingPath(loopId)
            .childByAppendingPath(userId)
            .childByAppendingPath(key)
            .setValue(value)
    }
    
    var REF_USER_CURRENT: Firebase {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        let loopId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_LOOP) as? String
        return REF_LOOP.childByAppendingPath(loopId).childByAppendingPath(userId)
    }
}