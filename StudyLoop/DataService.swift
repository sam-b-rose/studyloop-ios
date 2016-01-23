//
//  DataService.swift
//  StudyLoop
//
//  Created by Sam Rose on 11/29/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_QUEUES = Firebase(url: "\(URL_BASE)/queues")
    private var _REF_COURSES = Firebase(url: "\(URL_BASE)/courses")
    private var _REF_LOOP_MESSAGES = Firebase(url: "\(URL_BASE)/loop-messages")
    private var _REF_LOOPS = Firebase(url: "\(URL_BASE)/loops")
    private var _REF_MAJORS = Firebase(url: "\(URL_BASE)/majors")
    private var _REF_DEVICE_IDS = Firebase(url: "\(URL_BASE)/device-ids")
    private var _REF_UNIVERSITIES = Firebase(url: "\(URL_BASE)/universities")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }

    var REF_QUEUES: Firebase {
        return _REF_QUEUES
    }
    
    var REF_COURSES: Firebase {
        return _REF_COURSES
    }
    
    var REF_LOOP_MESSAGES: Firebase {
        return _REF_LOOP_MESSAGES
    }
    
    var REF_UNIVERSITIES: Firebase {
        return _REF_UNIVERSITIES
    }
    
    var REF_LOOPS: Firebase {
        return _REF_LOOPS
    }
    
    var REF_DEVICE_IDS: Firebase {
        return _REF_DEVICE_IDS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, AnyObject>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}