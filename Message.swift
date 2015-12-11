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
    private var _messageText: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _messageKey: String!
    private var _messageRef: Firebase!
    
    var messageText: String {
        return _messageText
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var messageKey: String {
        return _messageKey
    }
    
    init(text: String, imageUrl: String?, username: String) {
        self._messageText = text
        self._imageUrl = imageUrl
        self._username = username
    }
    
    init(messageKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._messageKey = messageKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        } else {
            self._likes = 0
        }

        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }

        if let messageText = dictionary["textValue"] as? String {
            self._messageText = messageText
        }
        
        self._messageRef = DataService.ds.REF_LOOP.childByAppendingPath(self._messageKey)
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