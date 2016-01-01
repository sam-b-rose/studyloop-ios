//
//  StateService.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/30/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class StateService {
    static let ss = StateService()
    
    private var _CURRENT_USER: User?
    private var _COURSES = [Course]()
    
    var CURRENT_USER: User? {
        return _CURRENT_USER
    }
    
    var COURSES: [Course]? {
        return _COURSES
    }
    
    func setUser(user: User) {
        _CURRENT_USER = user
    }
    
    func getCourses() {
        _COURSES = []
        let universityId = _CURRENT_USER?.universityId
        print("getting courses from", universityId)
        
        DataService.ds.REF_COURSES
            .queryOrderedByChild("universityId")
            .queryStartingAtValue(universityId)
            .queryEndingAtValue(universityId)
            .observeSingleEventOfType(.Value, withBlock: {
                snapshot in
                
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    for snap in snapshots {
                        print("SNAP: \(snap)")
                        
                        if let courseDict = snap.value as? Dictionary<String, AnyObject> {
                            // Create Course Object
                            let course = Course(dictionary: courseDict)
                            self._COURSES.append(course)
                            print(self._COURSES)
                        }
                    }
                }
                print("finished")
            })
    }
}