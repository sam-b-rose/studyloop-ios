//
//  university.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/5/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class University {
    private var _name: String!
    private var _shortName: String!
    private var _userIds: Dictionary<String, AnyObject>?
    private var _universityKey: String!
    private var _universityRef: Firebase!
    
    var shortName: String {
        return _shortName
    }
    
    var name: String {
        return _name
    }
    
    var universityKey: String {
        return _universityKey
    }
    
    init(name: String, shortName: String) {
        self._name = name
        self._shortName = shortName
    }
    
    init(universityKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._universityKey = universityKey

        if let name = dictionary["name"] as? String {
            self._name = name
        } else {
            print("No name found")
            self._name = ""
        }
        
        if let shortName = dictionary["shortName"] as? String {
            self._shortName = shortName
        } else {
            print("No short name found")
            self._shortName = ""
        }
        
        if let userIds = dictionary["userIds"] as? Dictionary<String, AnyObject> {
            self._userIds = userIds
        } else {
            print("No userIds found")
            self._userIds = nil
        }
        
        self._universityRef = DataService.ds.REF_UNIVERSITIES.childByAppendingPath(self._universityKey)
    }
    

    
    func addUser (userId: String) {
        _universityRef.childByAppendingPath("userIds").setValue(userId)
    }
}