//
//  JQMessage.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/27/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class JMessage : NSObject, JSQMessageData {
    var text_: String
    var senderId_: String
    var senderDisplayName_: String
    var isMediaMessage_: Bool
    var messageHash_: UInt
    var date_: NSDate
    var imageUrl_: String?
    
    convenience init(text: String?, sender: String?) {
        self.init(text: text, sender: sender, senderDisplayName: sender, date: NSDate(), imageUrl: nil)
    }
    
    init(text: String?, sender: String?, senderDisplayName: String?, date: NSDate!, imageUrl: String?) {
        self.text_ = text!
        self.senderId_ = sender!
        self.senderDisplayName_ = senderDisplayName!
        self.isMediaMessage_ = false
        self.date_ = date
        self.imageUrl_ = imageUrl
        
        let timestamp = UInt(floor(self.date_.timeIntervalSince1970 * 1000))
        self.messageHash_ = timestamp
    }
    
    init(dictionary: Dictionary<String, AnyObject>, displayName: String?, imageUrl: String?) {
        self.text_ = dictionary["textValue"] as! String
        self.senderId_ = dictionary["createdById"] as! String
        self.isMediaMessage_ = false
        self.imageUrl_ = imageUrl
        
        if displayName != nil{
            self.senderDisplayName_ = displayName!
        } else {
            self.senderDisplayName_ = "Anonymous"
        }
        
        if let createdAt = dictionary["createdAt"] as? Double {
            self.date_ = NSDate(timeIntervalSince1970: createdAt * 1000)
        } else {
            self.date_ = NSDate()
        }
        
        let timestamp = UInt(floor(self.date_.timeIntervalSince1970 * 1000))
        self.messageHash_ = timestamp
    }
    
    
    func text() -> String! {
        return text_
    }
    
    func senderId() -> String! {
        return senderId_
    }
    
    func senderDisplayName() -> String! {
        return senderDisplayName_
    }
    
    func messageHash() -> UInt {
        return messageHash_
    }
    
    func isMediaMessage() -> Bool {
        return isMediaMessage_
    }
    
    func date() -> NSDate! {
        return date_
    }
    
    func imageUrl() -> String? {
        return imageUrl_
    }
}