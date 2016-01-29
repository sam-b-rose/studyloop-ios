////
////  JSQMessageVC.swift
////  StudyLoop
////
////  Created by Sam Rose on 1/27/16.
////  Copyright © 2016 StudyLoop. All rights reserved.
////

import UIKit
import Foundation
import Firebase
import JSQMessagesViewController

class MessagesViewController: JSQMessagesViewController {
    
    var user: FAuthData?
    var loop: Loop?
    
    var messages = [JSQMessage]()
    var userImageMap = Dictionary<String, String>()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(SL_GREEN)
    var incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var senderImageUrl: String!
    var batchMessages = true
    
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef: Firebase!
    var avatarsRef: Firebase!
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
//        messagesRef = Firebase(url: "https://swift-chat.firebaseio.com/messages")
        messagesRef = DataService.ds.REF_LOOP_MESSAGES.childByAppendingPath(loop!.uid)
        avatarsRef = DataService.ds.REF_LOOPS.childByAppendingPath(loop!.uid).childByAppendingPath("userIds")
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        messagesRef.queryLimitedToLast(25).observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            var text: String!
            var senderId: String!
            var senderDisplayName: String!
            var date: NSDate!
            
            print("SNAP: ", snapshot)
            
            if let message = snapshot.value["textValue"] as? String {
                text = message
            } else {
                text = "Didn't get a text value."
            }
            
            if let sender = snapshot.value["createdById"] as? String {
                senderId = sender
            } else {
                senderId = "unknown sender"
            }
            
            if let senderName = snapshot.value["createdByName"] as? String {
                senderDisplayName = senderName
            } else {
                senderDisplayName = "unknown sender"
            }
            
            if let created = snapshot.value["createdAt"] as? Double {
                date = NSDate(timeIntervalSince1970: created * 1000)
            } else {
                date = NSDate()
            }
            
            // let message = JQMessage(text: text, sender: senderId, senderDisplayName: senderDisplayName, date: date, imageUrl: imageUrl)
            let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
            self.messages.append(message)
            self.finishReceivingMessage()
        })
        
        avatarsRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) -> Void in
            if let users = snapshot.value as? Dictionary<String, AnyObject> {
                self.createUserMaps(users, completion: { (result) -> Void in
                    print(result)
                })
            }
        })
    }
    
    func createUserMaps(users: Dictionary<String, AnyObject>, completion: (result: Bool)-> Void) {
        let userGroup = dispatch_group_create()
        
        for (user, inLoop) in users {
            dispatch_group_enter(userGroup)
            if userImageMap[user] == nil && inLoop as! Bool == true {
                DataService.ds.REF_USERS.childByAppendingPath(user).observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                    if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                        self.userImageMap[user] = userDict["profileImageURL"] as? String
                    }
                    dispatch_group_leave(userGroup)
                })
            }
        }
        
        dispatch_group_notify(userGroup, dispatch_get_main_queue()) {
            completion(result: true)
        }
    }

    
    func sendMessage(text: String!, sender: String!) {
        // *** STEP 3: ADD A MESSAGE TO FIREBASE
        messagesRef.childByAutoId().setValue([
            "textValue":text,
            "createdById": senderId,
            "createdByName": senderDisplayName,
            "loopId": loop!.uid,
            "createdAt": kFirebaseServerValueTimestamp,
            ])
    }
    
    func tempSendMessage(text: String!, sender: String!) {
//        let message = JQMessage(text: text, sender: senderId, senderDisplayName: senderId, date: NSDate(), imageUrl: senderImageUrl)
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), text: text)
        messages.append(message)
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
                    // avatars[name] = avatarImage
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
        
        //let rgbValue = name.hash
        //let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        //let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        //let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        //let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        let color = SL_LIGHT
        
        
        let nameLength = name.characters.count
        let initials : String? = name.substringToIndex(senderId!.startIndex.advancedBy(min(3, nameLength)))
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: SL_CORAL, font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        navigationController?.navigationBar.topItem?.title = ""
        
        senderId = (senderId != nil) ? senderId : "Anonymous"
        let profileImageUrl = user?.providerData["cachedUserProfile"]?["profile_image_url_https"] as? NSString
        if let urlString = profileImageUrl {
            setupAvatarImage(senderId, imageUrl: urlString as String, incoming: false)
            senderImageUrl = urlString as String
        } else {
            setupAvatarColor(senderId, incoming: false)
            senderImageUrl = ""
        }
        
        setupFirebase()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    // ACTIONS
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        sendMessage(text, sender: senderId)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return self.outgoingBubbleImage
        }
        
       return self.incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.senderId] {
            return avatar
        } else {
            setupAvatarImage(message.senderId, imageUrl: userImageMap[message.senderId], incoming: true)
            return nil
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = SL_BLACK
        }
        
        let attributes : [String:AnyObject] = [NSForegroundColorAttributeName:cell.textView!.textColor!, NSUnderlineStyleAttributeName: 1]
        cell.textView!.linkTextAttributes = attributes
        
        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.senderId == senderId {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.senderId)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.senderId == senderId {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}

