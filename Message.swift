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
    private var _imageUrl: String?
    private var _likes: Int!
    private var _loopId: String!
    private var _courseId: String!
    private var _createdAt: Int?
    private var _createdById: String!
    private var _createdByName: String!
    private var _messageKey: String!
    private var _messageRef: Firebase!
    
    var textValue: String {
        return _textValue
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var createdAt: Int? {
        return _createdAt
    }
    
    var createdById: String {
        return _createdById
    }
    
    var createdByName: String {
        return _createdByName
    }
    
    var messageKey: String {
        return _messageKey
    }
    
    init(text: String, imageUrl: String?, createdByName: String, createdById: String) {
        self._textValue = text
        self._imageUrl = imageUrl
        self._createdByName = createdByName
        self._createdByName = createdById
    }
    
    init(messageKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._messageKey = messageKey
        self._textValue = dictionary["textValue"] as? String
        self._createdById = dictionary["createdById"] as? String
        self._createdByName = dictionary["createdByName"] as? String
        self._loopId = dictionary["loopId"] as? String
        self._courseId = dictionary["courseId"] as? String
        
        if let createdAt = dictionary["createdAt"] as? Int {
            self._createdAt = createdAt
        } else {
            self._createdAt = nil
        }
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        } else {
            self._likes = 0
        }

        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
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