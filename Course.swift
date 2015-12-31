//
//  Course.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/30/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class Course {
    private var _uid: String!
    private var _instructor: String!
    private var _major: String!
    private var _name: String!
    private var _universityId: String!
    private var _courseRef: Firebase!
    
    var uid: String {
        return _uid
    }
    
    var instructor: String {
        return _instructor
    }
    
    var major: String {
        return _major
    }
    
    var name: String {
        return _name
    }
    
    var universityId: String? {
        return _universityId
    }
    
    init(uid: String, instructor: String, major: String, name: String, universityId: String) {
        self._uid = uid
        self._instructor = instructor
        self._major = major
        self._name = name
        self._universityId = universityId
    }
    
    init(dictionary: Dictionary<String, AnyObject?>) {
        self._uid = dictionary["id"] as? String
        self._instructor = dictionary["instructor"] as? String
        self._major = dictionary["major"] as? String
        self._name = dictionary["name"] as? String
        self._universityId = dictionary["universityId"] as? String
    }
}
