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
    private var _uid: String!
    private var _name: String!
    private var _facebookId: String?
    private var _profileImgUrl: String?
    private var _courseIds: Dictionary<String, Bool>?
    private var _universityId: String?
    private var _userRef: Firebase!
    
    var email: String {
        return _email
    }
    
    var uid: String {
        return _uid
    }
    
    var name: String {
        return _name
    }
    
    var facebookId: String? {
        return _facebookId
    }
    
    var profileImgUrl: String? {
        return _profileImgUrl
    }
    
    var courseIds: Dictionary<String, Bool>? {
        return _courseIds
    }
    
    var universityId: String? {
        return _universityId
    }
    
    init(uid: String, email: String, name: String) {
        self._uid = uid
        self._email = email
        self._name = name
    }
    
    init(userKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._uid = userKey
        
        if let profileImgUrl = dictionary["imageUrl"] as? String {
            self._profileImgUrl = profileImgUrl
        }
        
        self._userRef = DataService.ds.REF_USERS.childByAppendingPath(self._uid)
    }
}
