//
//  Loop.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation

class Loop {
    private var _uid: String!
    private var _courseId: String!
    private var _createdAt: String!
    private var _subject: String!
    private var _universityId: String!
    private var _lastMessage: String!
    private var _hasCurrentUser: Bool!
    private var _userIds: [String]!
    
    var uid: String {
        return _uid
    }
    
    var courseId: String {
        return _courseId
    }
    
    var subject: String {
        return _subject
    }
    
    var createdAt: String {
        return _createdAt
    }
    
    var universityId: String {
        return _universityId
    }
    
    var lastMessage: String {
        get {
            return _lastMessage
        }
        set(newLastMessage) {
            _lastMessage = newLastMessage
        }
    }
    
    var hasCurrentUser: Bool {
        get {
            return _hasCurrentUser
        }
        set(hasUser) {
            _hasCurrentUser = hasUser
        }
    }
    
    var userIds: [String] {
        return _userIds
    }
    
    init(uid: String, courseId: String, createdAt: String, subject: String, universityId: String, lastMessage: String, userIds: Dictionary<String, Int>) {
        self._uid = uid
        self._courseId = courseId
        self._createdAt = createdAt
        self._subject = subject
        self._universityId = universityId
        
        self._lastMessage = lastMessage
        self._hasCurrentUser = false
        
        self._userIds = [String]()
        for (user, _) in userIds {
            self._userIds.append(user)
        }
    }
    
    init(uid: String, loopDict: Dictionary<String, AnyObject>) {
        self._uid = uid
        self._courseId = loopDict["courseId"] as? String
        self._createdAt = loopDict["createdAt"] as? String
        self._subject = loopDict["subject"] as? String
        self._universityId = loopDict["universityId"] as? String
        self._hasCurrentUser = false
        
        if let last = loopDict["lastMessage"] as? String {
            self._lastMessage = last
        } else {
            self._lastMessage = ""
        }
        
        self._userIds = [String]()
        if let userIdsDict = loopDict["userIds"] as? Dictionary<String, Int> {
            for (user, _) in userIdsDict {
                self._userIds.append(user)
            }
        }
    }
}