//
//  Notification.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/26/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class Notification {
    
    private var _uid: String!
    private var _type: String!
    private var _courseId: String!
    private var _createdAt: Double!
    private var _createdById: String!
    
    private var _loopId: String?
    private var _subject: String?
    private var _textValue: String?
    private var _universityId: String?
    
    var uid: String {
        return _uid
    }
    
    var type: String {
        return _type
    }
    
    var courseId: String {
        return _courseId
    }
    
    var createdAt: Double {
        return _createdAt
    }
    
    var createdById: String {
        return _createdById
    }
    
    var loopId: String? {
        return _loopId
    }
    
    var subject: String? {
        return _subject
    }
    
    var textValue: String? {
        return _textValue
    }
    
    var universityId: String? {
        return _universityId
    }
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self._uid = key
        self._type = dictionary["type"] as! String
        
        if let data = dictionary["data"] as? Dictionary<String, AnyObject> {
            self._courseId = data["courseId"] as! String
            self._createdAt = data["createdAt"] as! Double
            self._createdById = data["createdById"] as! String
            
            switch dictionary["type"] as! String {
            case "LOOP_MESSAGE_RECEIVED":
                self._loopId = data["loopId"] as? String
                self._textValue = data["textValue"] as? String
                break
            case "LOOP_CREATED":
                self._loopId = data["id"] as? String
                self._subject = data["subject"] as? String
                self._universityId = data["universityId"] as? String
                break
            default:
                break
            }
        }
    }
}