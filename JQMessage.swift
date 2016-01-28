//
//  JQMessage.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/27/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class JQMessage : NSObject, JSQMessageData {
    var text_: String
    var sender_: String
    var senderDisplayName_: String
    var isMediaMessage_: Bool
    var messageHash_: UInt
    var date_: NSDate
    var imageUrl_: String?
    
    convenience init(text: String?, sender: String?) {
        self.init(text: text, sender: sender, senderDisplayName: sender, imageUrl: nil)
    }
    
    init(text: String?, sender: String?, senderDisplayName: String?, imageUrl: String?) {
        self.text_ = text!
        self.sender_ = sender!
        self.senderDisplayName_ = senderDisplayName!
        self.isMediaMessage_ = false
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
        
        let timestamp = UInt(floor(self.date_.timeIntervalSince1970 * 1000))
        self.messageHash_ = timestamp
    }
    
    func text() -> String! {
        return text_
    }
    
    func senderId() -> String! {
        return sender_
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