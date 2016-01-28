//
//  UserService.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/19/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class UserService {
    static let us = UserService()
    
    var authData: FAuthData?
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private var _REF_USER_SETTINGS = Firebase(url: "\(URL_BASE)/user-settings")
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USER_SETTINGS: Firebase {
        return _REF_USER_SETTINGS
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, AnyObject>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
    func setMuteCourse(isMuted: Bool) {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let courseId = NSUserDefaults.standardUserDefaults().valueForKey(KEY_COURSE) as! String
        REF_USER_SETTINGS.childByAppendingPath(uid).childByAppendingPath("mutedCourses").childByAppendingPath(courseId).setValue(isMuted)
    }
    
    func setMuteLoop(loopId: String, isMuted: Bool) {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        REF_USER_SETTINGS.childByAppendingPath(uid).childByAppendingPath("mutedLoops").childByAppendingPath(loopId).setValue(isMuted)
    }
}