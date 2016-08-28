//
//  SLMessage.swift
//  StudyLoop
//
//  Created by Sam Rose on 2/4/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import Alamofire
import JSQMessagesViewController

class SLMessage : JSQMessage {
    
    private var _avatarUrl: String?
    private var _attachmentUrl: String?
    
    var avatarUrl: String? {
        return _avatarUrl
    }
    
    var attachmentUrl: String? {
        return _attachmentUrl
    }
    
    init!(senderId: String!, senderDisplayName: String!, date: NSDate!, text: String!, avatarUrl: String?) {
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        self._avatarUrl = avatarUrl
    }
    
    init!(senderId: String!, senderDisplayName: String!, date: NSDate!, media: JSQMessageMediaData!, attachmentUrl: String!, avatarUrl: String?) {
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: media)
        
        self._attachmentUrl = attachmentUrl
        self._avatarUrl = avatarUrl
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}