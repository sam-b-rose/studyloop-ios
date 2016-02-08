//
//  User.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/10/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class User {
    private var _email: String!
    private var _id: String!
    private var _name: String!
    private var _provider: String!
    private var _updatedAt: String!
    private var _createdAt: String!
    private var _profileImageURL: String?
    private var _courseIds: Dictionary<String, Int>?
    private var _universityId: String?
    private var _isTemporaryPassword: Int?
    private var _userRef: Firebase!
    
    var email: String {
        return _email
    }
    
    var id: String {
        return _id
    }
    
    var name: String {
        return _name
    }
    
    var provider: String {
        return _provider
    }
    
    var updatedAt: String {
        return _updatedAt
    }
    
    var createdAt: String {
        return _createdAt
    }
    
    var profileImageURL: String? {
        return _profileImageURL
    }
    
    var courseIds: Dictionary<String, Int>? {
        return _courseIds
    }
    
    var universityId: String? {
        return _universityId
    }
    
    var isTemporaryPassword: Int? {
        get {
            return _isTemporaryPassword
        }
        set(isTemp) {
            _isTemporaryPassword = isTemp
        }
    }
    
    init(uid: String, dictionary: Dictionary<String, AnyObject?>) {
        self._id = uid
        self._email = dictionary["email"] as? String
        self._provider = dictionary["provider"] as? String
        
        // Update when saving to Firebase
        self._createdAt = nil
        self._updatedAt = nil

        if dictionary["name"] != nil {
            self._name = dictionary["name"] as? String
        }
        
        if dictionary["profileImageURL"] != nil {
            self._profileImageURL = dictionary["profileImageURL"] as? String
        }
        
        if dictionary["universityId"] != nil {
            self._universityId = dictionary["universityId"] as? String
        } else {
            self._universityId = nil
        }
        
        if dictionary["courseIds"] != nil {
            self._courseIds = dictionary["courseIds"] as? Dictionary<String, Int>
        } else {
            self._courseIds = Dictionary<String, Int>()
        }
    }
    
    func setUniversity(universityId: String) {
        UserService.us.REF_USER_CURRENT.childByAppendingPath("universityId").setValue(universityId)
        _universityId = universityId
    }
    
    func addCourse(courseId: String) {
        UserService.us.REF_USER_CURRENT.childByAppendingPath("courseIds").childByAppendingPath(courseId).setValue(true)
        _courseIds![courseId] = 1
    }
}
