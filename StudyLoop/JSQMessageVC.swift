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
    
    var loop: Loop!
    var messages = [JMessage]()
    var userImageMap = Dictionary<String, String>()
    var userNameMap = Dictionary<String, String>()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    var outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(SL_LIGHT)
    var incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(SL_GRAY.colorWithAlphaComponent(0.2))
    
    var timer: NSTimer? = nil
    var cameraButton: UIButton!
    
    var activityRef: Firebase!
    var messagesRef: Firebase!
    var usersRef: Firebase!
    
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    
    func monitorActivity() {
        // Monitor User Activity
        activityRef = ActivityService.act.REF_ACTIVITY_LOOP.childByAppendingPath(loop.uid)
            
        activityRef.observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            print("SNAP: ", snapshot)
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.checkIfTyping(snapshot.key, user: userDict)
            }
        })
        
        // Set that user is active in loop
        ActivityService.act.REF_ACTIVITY_LOOP
            .childByAppendingPath(loop.uid)
            .childByAppendingPath(senderId)
            .updateChildValues([
                "activeAt": kFirebaseServerValueTimestamp,
                "presentAt": kFirebaseServerValueTimestamp
                ])
        
        // Set last loop for current user
        ActivityService.act.setLastLoop(loop.uid)
    }
    
    func getUsers() {
        usersRef = DataService.ds.REF_LOOPS.childByAppendingPath(loop.uid).childByAppendingPath("userIds")
        
        usersRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if let users = snapshot.value as? Dictionary<String, AnyObject> {
                self.createUserMaps(users, completion: { (result) -> Void in
                    self.getMessages()
                })
            }
        })
    }
    
    func getMessages() {
        messagesRef = DataService.ds.REF_LOOP_MESSAGES.childByAppendingPath(loop.uid)
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        self.messagesRef.queryLimitedToLast(25).observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            if let messageDict = snapshot.value as? Dictionary<String, AnyObject> {
                if let senderId = messageDict["createdById"] as? String {
                    let message = JMessage(key: snapshot.key, dictionary: messageDict, displayName: self.userNameMap[senderId], imageUrl: self.userImageMap[senderId])
                    self.messages.append(message)
                    self.finishReceivingMessage()
                }
            }
        })
    }
    
    func createUserMaps(users: Dictionary<String, AnyObject>, completion: (result: Bool)-> Void) {
        let userGroup = dispatch_group_create()
        for (user, inLoop) in users {
            if userImageMap[user] == nil && inLoop as! Bool == true {
                dispatch_group_enter(userGroup)
                DataService.ds.REF_USERS.childByAppendingPath(user).observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                    if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                        self.userImageMap[user] = userDict["profileImageURL"] as? String
                        self.userNameMap[user] = userDict["name"] as? String
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
        messagesRef.childByAutoId().setValue([
            "textValue":text,
            "createdById": senderId,
            "loopId": loop.uid,
            "courseId": NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as! String,
            "createdAt": kFirebaseServerValueTimestamp,
            ])
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        print("Avatar Setup", name, imageUrl, incoming)
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let color = SL_LIGHT

        let nameLength = name.characters.count
        let initials : String? = name.substringToIndex(senderId!.startIndex.advancedBy(min(3, nameLength)))
        let userImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: SL_CORAL, font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyScrollsToMostRecentMessage = true
        
        // Navbar Stuff
        let more = UIBarButtonItem(title: String.ioniconWithName(.More), style: .Plain, target: self, action: Selector("goToLoopSettings"))
        self.navigationItem.rightBarButtonItem = more
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes(attributes, forState: .Normal)
        self.navigationItem.title = loop.subject
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
        
        ////// Attachment Button //////
        inputToolbar!.contentView!.leftBarButtonItem = nil
        cameraButton = UIButton(type: .Custom)
        cameraButton.titleLabel?.font = UIFont.ioniconOfSize(20)
        cameraButton.titleLabel?.textAlignment = .Center;
        cameraButton.setTitle(String.ioniconWithName(.Camera), forState: .Normal)
        cameraButton.frame = CGRectMake(0, 0, 22, 32);
        
        senderId = (senderId != nil) ? senderId : "Anonymous"
        getUsers()
        monitorActivity()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove Notifications
        let loopNotifications = NotificationService.noti.notifications.filter { $0.loopId == loop.uid }
        for notification in loopNotifications {
            NotificationService.noti.removeNotification(notification.uid)
        }
    }
    
    // ACTIONS
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        sendMessage(text, sender: senderId)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
    }
    
    // Typing
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange((self.inputToolbar?.contentView?.textView)!)

        // Watch user text input to update isTyping indicator
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateTypingIndicator:"), userInfo: self.inputToolbar?.contentView?.textView, repeats: false)
    }
    
    func updateTypingIndicator(timer: NSTimer) {
        if let textView = timer.userInfo! as? UITextView {
            if textView.text != "" {
                print("setting typing")
                ActivityService.act.setUserActivity(loop.uid, userId: senderId!, key: "typingAt", value: kFirebaseServerValueTimestamp)
            } else {
                ActivityService.act.setUserActivity(loop.uid, userId: senderId!, key: "typingAt", value: 0)
            }
        }
    }
    
    
    func checkIfTyping(uid: String, user: Dictionary<String, AnyObject>) {
        if senderId != uid {
            if let typing = user["typingAt"] as? Int where typing > 0 {
                showTypingIndicator = true
            } else {
                showTypingIndicator = false
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        
        if message.senderId() == senderId {
            return self.outgoingBubbleImage
        }
        
        return self.incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.senderId()] {
            return avatar
        } else {
            setupAvatarImage(message.senderId(), imageUrl: message.imageUrl(), incoming: true)
            return nil
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.textView!.textColor = SL_BLACK
        
        let attributes : [String:AnyObject] = [NSForegroundColorAttributeName: SL_GREEN, NSUnderlineStyleAttributeName: 1]
        cell.textView!.linkTextAttributes = attributes
        
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        // Sent by me, skip
        if message.senderId() == senderId {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId() == message.senderId() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.senderDisplayName())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.senderId() == senderId {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId() == message.senderId() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    // Segue Prep
    
    func goToLoopSettings() {
        performSegueWithIdentifier(SEGUE_LOOP_SETTINGS, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SEGUE_LOOP_SETTINGS) {
            let loopSettingsVC = segue.destinationViewController as! LoopSettingsVC
            loopSettingsVC.loopId = self.loop.uid
            loopSettingsVC.userIds = self.loop.userIds
        }
    }
}

