//
//  DataService.swift
//  StudyLoop
//
//  Created by Sam Rose on 11/29/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://studyloop-stage.firebaseio.com"

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_COURSES = Firebase(url: "\(URL_BASE)/courses")
    private var _REF_LOOP_MESSAGES = Firebase(url: "\(URL_BASE)/loop-messages")
    private var _REF_LOOPS = Firebase(url: "\(URL_BASE)/loops")
    private var _REF_MAJORS = Firebase(url: "\(URL_BASE)/majors")
    private var _REF_UID_MAPPING = Firebase(url: "\(URL_BASE)/uid-mapping")
    private var _REF_UNIVERSITIES = Firebase(url: "\(URL_BASE)/universities")
    // private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    
    // for Dev Only
    private var _REF_LOOP = Firebase(url: "\(URL_BASE)/ios-loop")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/ios-users")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_LOOP_MESSAGES: Firebase {
        return _REF_LOOP_MESSAGES
    }
    
    var REF_LOOP: Firebase {
        return _REF_LOOP
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("ios-users").childByAppendingPath(uid)
        return user!
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}