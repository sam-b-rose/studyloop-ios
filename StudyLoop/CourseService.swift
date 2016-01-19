//
//  CourseService.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/19/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class CourseService {
    static let cs = CourseService()
    
    private var _REF_COURSES = Firebase(url: "\(URL_BASE)/courses")
    private var _COURSES = [Course]()
    
    var REF_COURSES: Firebase {
        return _REF_COURSES
    }
    
    var COURSES: [Course]? {
        return _COURSES
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    func addUserToCourse(courseId: String, courseTitle: String, userId: String) {
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("courseIds").childByAppendingPath(courseId).setValue(true, withCompletionBlock: {
            error, ref in
            if error == nil {
                self.REF_COURSES.childByAppendingPath(courseId).childByAppendingPath("userIds").childByAppendingPath(userId).setValue(true)
                // Set Defaults
                NSUserDefaults.standardUserDefaults().setObject(courseId, forKey: KEY_COURSE)
                NSUserDefaults.standardUserDefaults().setObject(courseTitle, forKey: KEY_COURSE_TITLE)

                // Success
                NotificationService.noti.success("You have been added to \(courseTitle).")
            } else {
                // Error
                NotificationService.noti.error()
            }
            
        })

    }
    
    func getCourses(completion: (result: String) -> Void) {
        _COURSES.removeAll()
        let universityId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UNIVESITY)
        
        REF_COURSES
            .queryOrderedByChild("universityId")
            .queryStartingAtValue(universityId)
            .queryEndingAtValue(universityId)
            .observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    for snap in snapshots {
                        
                        if let courseDict = snap.value as? Dictionary<String, AnyObject> {
                            // Create Course Object
                            let course = Course(dictionary: courseDict)
                            self._COURSES.append(course)
                        }
                    }
                    completion(result: "Finished Loading Courses")
                }
            })
    }
}