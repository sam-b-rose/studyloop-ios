//
//  JQMessage.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/27/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import Alamofire
import JSQMessagesViewController

class JMessage : NSObject, JSQMessageData {
    var key_: String
    var text_: String
    var senderId_: String
    var senderDisplayName_: String
    var isMediaMessage_: Bool
    var date_: NSDate
    var media_: JSQMessageMediaData?
    var imageUrl_: String?
    var attachmentUrl_: String?
    
    var request: Request?
    
    convenience init(text: String?, sender: String?) {
        self.init(text: text, sender: sender, senderDisplayName: sender, date: NSDate())
    }
    
    init(text: String?, sender: String?, senderDisplayName: String?, date: NSDate!) {
        self.key_ = "\(sender!)\(text!)\(date!)"
        self.text_ = text!
        self.senderId_ = sender!
        self.senderDisplayName_ = senderDisplayName!
        self.date_ = date
        self.isMediaMessage_ = false
        self.media_ = nil
        self.imageUrl_ = nil
        self.attachmentUrl_ = nil
    }
    
    init(key: String, dictionary: Dictionary<String, AnyObject>, displayName: String?, imageUrl: String?) {
        self.key_ = key
        self.text_ = dictionary["textValue"] as! String
        self.senderId_ = dictionary["createdById"] as! String
        self.isMediaMessage_ = false
        self.imageUrl_ = imageUrl
        self.media_ = nil
        
        if displayName != nil{
            self.senderDisplayName_ = displayName!
        } else {
            self.senderDisplayName_ = "Anonymous"
        }
        
        if let createdAt = dictionary["createdAt"] as? Double {
            self.date_ = NSDate(timeIntervalSince1970: createdAt)
        } else {
            self.date_ = NSDate()
        }
        
        if let attachment = dictionary["attachment"] as? Dictionary<String, AnyObject> {
            if let path = attachment["path"] as? String {
                self.isMediaMessage_ = false
                self.attachmentUrl_ = path
                let image = UIImage(named: "owl-light-bg")
                self.media_ = JSQPhotoMediaItem(image: image)
            }
        }
    }
    
    func messageHash() -> UInt {
        //let contentHash = self.isMediaMessage() ? self.attachmentUrl_?.hash : self.text_.hash
        //return UInt(abs(self.senderId_.hash ^ self.date_.hash ^ contentHash!))
        return UInt(abs(self.key_.hash))
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