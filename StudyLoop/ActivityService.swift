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
    
    // Activity Indicator
    private var _ACT_IND: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // Firebase REFS
    private var _REF_ACTIVITY = Firebase(url: "\(URL_BASE)/user-activity")
    private var _REF_ACTIVITY_LOOP = Firebase(url: "\(URL_BASE)/user-activity/loops")
    private var _REF_ACTIVITY_USERS = Firebase(url: "\(URL_BASE)/user-activity/users")
    
    
    var REF_ACTIVITY: Firebase {
        return _REF_ACTIVITY
    }
    
    var REF_ACTIVITY_LOOP: Firebase {
        return _REF_ACTIVITY_LOOP
    }
    
    var REF_ACTIVITY_USERS: Firebase {
        return _REF_ACTIVITY_USERS
    }
    
    var ACT_IND: UIActivityIndicatorView {
        return _ACT_IND
    }
    
    var REF_USER_CURRENT: Firebase {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        let loopId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_LOOP) as? String
        return REF_ACTIVITY_LOOP.childByAppendingPath(loopId).childByAppendingPath(userId)
    }
    
    
  
    
    // User Activity helper functions
    
    func setUserActivity(loopId: String, userId: String, key: String, value: AnyObject) {
        REF_ACTIVITY_LOOP.childByAppendingPath(loopId)
            .childByAppendingPath(userId)
            .childByAppendingPath(key)
            .setValue(value)
    }
    
    
    
    
    // User's Last Loop and Last Course
    
    func setLastLoop(loopId: String) {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        REF_ACTIVITY_USERS.childByAppendingPath(userId).childByAppendingPath("loopId").setValue(loopId)
    }
    
    func getLastLoop(completion: (result: String) -> Void) {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        REF_ACTIVITY_USERS.childByAppendingPath(userId).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let userActivityDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let loopId = userActivityDict["loopId"] as? String {
                    completion(result: loopId)
                }
            }
        })
    }
    
    func setLastCourse(courseId: String) {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        REF_ACTIVITY_USERS.childByAppendingPath(userId).childByAppendingPath("courseId").setValue(courseId)
    }
   
    func getLastCourse(completion: (result: String) -> Void) {
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        REF_ACTIVITY_USERS.childByAppendingPath(userId).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let userActivityDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let courseId = userActivityDict["courseId"] as? String {
                    completion(result: courseId)
                }
            }
        })
    }
    
    
    
    
    // Activity Indicator
    
    func showActivityIndicator(dark: Bool, uiView: UIView) {
        ACT_IND.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        ACT_IND.center = uiView.center
        ACT_IND.hidesWhenStopped = true
        
        if dark {
            ACT_IND.activityIndicatorViewStyle = .Gray
        } else {
            ACT_IND.activityIndicatorViewStyle = .WhiteLarge
        }
        
        uiView.addSubview(ACT_IND)
        ACT_IND.startAnimating()
    }
    
    func hideActivityIndicatior() {
        ACT_IND.stopAnimating()
    }
}