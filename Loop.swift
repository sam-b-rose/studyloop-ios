//
//  Loop.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation

class Loop {
    private var _courseId: String!
    private var _createdAt: String!
    private var _subject: String!
    private var _universityId: String!
    private var _userIds: [String]!
    
    var courseId: String {
        return _courseId
    }
    
    var subject: String {
        return _subject
    }
    
    var universityId: String {
        return _universityId
    }
    
    var userIds: [String] {
        return _userIds
    }
    
    init(courseId: String, createdAt: String, subject: String, universityId: String, userIds: Dictionary<String, Int>) {
        self._courseId = courseId
        self._createdAt = createdAt
        self._subject = subject
        self._universityId = universityId
        
        self._userIds = [String]()
        for (user, _) in userIds {
            self._userIds.append(user)
        }
    }
    
    init(loopDict: Dictionary<String, AnyObject>) {
        self._courseId = loopDict["courseId"] as? String
        self._createdAt = loopDict["createdAt"] as? String
        self._subject = loopDict["subject"] as? String
        self._universityId = loopDict["universityId"] as? String
        
        self._userIds = [String]()
        if let userIdsDict = loopDict["userIds"] as? Dictionary<String, Int> {
            for (user, _) in userIdsDict {
                self._userIds.append(user)
            }
        }
    }
}