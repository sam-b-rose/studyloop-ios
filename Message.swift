//
//  message.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/5/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class Message {
    private var _textValue: String!
    private var _attachmentUrl: String?
    private var _likes: Int!
    private var _loopId: String!
    private var _courseId: String!
    private var _createdAt: Double!
    private var _createdById: String!
    private var _messageKey: String!
    private var _messageRef: Firebase!
    
    var textValue: String {
        return _textValue
    }
    
    var attachmentUrl: String? {
        return _attachmentUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var createdAt: Double {
        return _createdAt
    }
    
    var createdById: String {
        return _createdById
    }
    
    var messageKey: String {
        return _messageKey
    }
    
    init(messageKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._messageKey = messageKey
        self._textValue = dictionary["textValue"] as? String
        self._createdById = dictionary["createdById"] as? String
        self._loopId = dictionary["loopId"] as? String
        self._courseId = dictionary["courseId"] as? String
        
        if let createdAt = dictionary["createdAt"] as? Double {
            self._createdAt = createdAt
        } else if let createdAt = dictionary["createdAt"] as? String {
            self._createdAt = Double(createdAt)
        }
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        } else {
            self._likes = 0
        }

        if let attachment = dictionary["attachment"] as? Dictionary<String, AnyObject> {
            if let path = attachment["path"] as? String {
                self._attachmentUrl = path
            }
        }
        
        self._messageRef = DataService.ds.REF_LOOP_MESSAGES.childByAppendingPath(self._messageKey)
    }
    
    func adjustLikes (addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _messageRef.childByAppendingPath("likes").setValue(_likes)
    }
}