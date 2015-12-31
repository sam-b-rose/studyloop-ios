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
    private var _facebookId: String?
    private var _profileImageURL: String?
    private var _courseIds: Dictionary<String, Bool>?
    private var _universityId: String?
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
    
    var facebookId: String? {
        return _facebookId
    }
    
    var profileImageURL: String? {
        return _profileImageURL
    }
    
    var courseIds: Dictionary<String, Bool>? {
        return _courseIds
    }
    
    var universityId: String? {
        return _universityId
    }
    
    init(uid: String, email: String, name: String?, profileImageURL: String?) {
        self._id = uid
        self._email = email
        
        if name != nil {
            self._name = name
        }
        
        if profileImageURL != nil {
            self._profileImageURL = profileImageURL
        }
        
        // initialize to empty
        self._universityId = nil
        self._courseIds = nil
    }
    
    init(dictionary: Dictionary<String, AnyObject?>) {
        self._id = dictionary["id"] as? String
        self._email = dictionary["email"] as? String

        if dictionary["name"] != nil {
            self._name = dictionary["name"] as? String
        }
        
        if dictionary["profileImageURL"] != nil {
            self._profileImageURL = dictionary["profileImageURL"] as? String
        }
        
        // initialize to empty
        self._universityId = nil
        self._courseIds = nil
    }
    
    func setUniversity(universityId: String) {
        _universityId = universityId
    }
}
