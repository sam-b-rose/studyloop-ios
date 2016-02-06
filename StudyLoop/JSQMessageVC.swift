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
import Alamofire
import JSQMessagesViewController
import JTSImageViewController
import AHKActionSheet

class MessagesViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var loop: Loop!
    var messages = [SLMessage]()
    var userImageMap = Dictionary<String, String>()
    var userNameMap = Dictionary<String, String>()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    var imagePicker: UIImagePickerController!
    static var imageCache = NSCache()
    var imageToSend: UIImage!
    var imageName = ""
    
    var outgoingBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(SL_LIGHT)
    var incomingBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(SL_GRAY.colorWithAlphaComponent(0.2))
    
    var request: Request?
    var timer: NSTimer? = nil
    var cameraButton: UIButton!
    
    var activityRef: Firebase!
    var messagesRef: Firebase!
    var messagesQueueRef: Firebase!
    var usersRef: Firebase!
    
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    
    
    
    /* Firebase / Gettin Data */
    
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
        messagesQueueRef = DataService.ds.REF_QUEUES
        
        // TODO: Currently limitied to last 25 messages
        self.messagesRef.queryLimitedToLast(25).observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            if let messageDict = snapshot.value as? Dictionary<String, AnyObject> {
                let message: SLMessage!
                
                let text = messageDict["textValue"] as! String
                let senderId = messageDict["createdById"] as! String
                let senderDisplayName = self.userNameMap[senderId] != nil ? self.userNameMap[senderId]! : "Anonymous"
                
                var date = NSDate()
                let avatarUrl = self.userImageMap[senderId]
                
                if let createdAt = messageDict["createdAt"] as? Double {
                    date = NSDate(timeIntervalSince1970: createdAt)
                }
                
                if let attachment = messageDict["attachment"] as? Dictionary<String, AnyObject>,
                    let path = attachment["path"] as? String {
                        let attachmentUrl = path
                        let photoMedia = JSQPhotoMediaItem(image: nil)
                        photoMedia.appliesMediaViewMaskAsOutgoing = (senderId == self.senderId)
                        message = SLMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: photoMedia, attachmentUrl: attachmentUrl, avatarUrl: avatarUrl)
                        self.messages.append(message)
                } else {
                    message = SLMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text, avatarUrl: avatarUrl)
                    self.messages.append(message)
                }
                
                self.finishReceivingMessage()
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
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
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
    
    
    
    // MARK: - View Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyScrollsToMostRecentMessage = true
        collectionView!.collectionViewLayout.messageBubbleFont = UIFont.init(name: "Noto Sans", size: 14)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // Navbar Stuff
        let more = UIBarButtonItem(title: String.ioniconWithName(.More), style: .Plain, target: self, action: Selector("goToLoopSettings"))
        self.navigationItem.rightBarButtonItem = more
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes(attributes, forState: .Normal)
        self.navigationItem.title = loop.subject
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
        
        senderId = (senderId != nil) ? senderId : "Anonymous"
        
        // Firebase calls
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
    
    
    
    // MARK: - Image Picker
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: {
            let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
            self.imageName = imageURL.lastPathComponent!
            self.imageToSend = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.confirmImageChoice()
        })
    }
    
    func confirmImageChoice() {
        let confirm = AHKActionSheet(title: nil)
        
        confirm.blurTintColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
        confirm.blurRadius = 8.0
        confirm.buttonHeight = 50.0
        confirm.cancelButtonHeight = 50.0
        confirm.animationDuration = 0.5
        confirm.cancelButtonShadowColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        confirm.separatorColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        confirm.selectedBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        confirm.buttonTextAttributes = [
            NSFontAttributeName: UIFont(name: "Noto Sans", size: 17)!,
            NSForegroundColorAttributeName: SL_WHITE
        ]
        
        let imageHeader = ImageConfirmView(frame: CGRectMake(0, 0, 200,60))
        imageHeader.configureImageConfirm(imageToSend)
        confirm.headerView = imageHeader
        
        confirm.addButtonWithTitle("Send", type: AHKActionSheetButtonType.Default, handler: {
            AHKActionSheet in
            self.sendImage()
        })
        
        confirm.addButtonWithTitle("Reselect", type: AHKActionSheetButtonType.Default, handler: {
            AHKActionSheet in
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        })
        
        confirm.show()
    }
    
    func sendImage() {
        let image = UIImageJPEGRepresentation(imageToSend, 0.2)
        let sizeBytes = image!.length
        if sizeBytes < 10000000 {
            let base64Image = "data:image/jpeg;base64," + image!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            let imageData: Dictionary<String, AnyObject> = [
                "image": base64Image,
                "size": sizeBytes,
                "caption": ""
            ]
            sendMessage("", sender: senderId, imageData: imageData)
        } else {
            NotificationService.noti.showAlert("Image to Large", msg: "Image attchment is over the max 10MB limit.", uiView: self)
        }
    }
    
    
    
    
    // MARK: - Input Bar Actions
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        sendMessage(text, sender: senderId, imageData: nil)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // TODO: Add Ability to send Image
    func sendMessage(text: String!, sender: String!, imageData: Dictionary<String, AnyObject>?) {
        var message: Dictionary<String, AnyObject> = [
            "textValue":text,
            "createdById": senderId,
            "loopId": loop.uid,
            "courseId": NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as! String,
            "createdAt": kFirebaseServerValueTimestamp,
        ]
        
        if imageData != nil {
            // Compose Media Messaage
            let time = NSDate().timeIntervalSince1970
            let queueId: String! = "\(senderId!)_\(time)_\(imageName)"
            
            message["name"] = imageName
            message["dataURI"] = imageData!["image"]
            message["queueId"] = queueId
            message["sizeBytes"] = imageData!["size"]
            message["textValue"] = imageData!["caption"]
            message["type"] = "image/jpeg"
            DataService.ds.REF_QUEUES.childByAppendingPath("loop-message-attachments").childByAppendingPath("tasks").childByAutoId().setValue(message)
        } else {
            // Standard Text Message
            messagesQueueRef.childByAppendingPath("loop-messages").childByAppendingPath("tasks").childByAutoId().setValue(message)
            messagesRef.childByAutoId().setValue(message, withCompletionBlock: {
                error, ref in
                if error == nil {
                    DataService.ds.REF_LOOPS.childByAppendingPath(self.loop.uid).updateChildValues([
                        "lastMessage": "\(self.userNameMap[sender]!): \(text)",
                        "updatedAt": kFirebaseServerValueTimestamp
                        ])
                }
            })
        }
    }
    
    
    
    /* Typing Indicator Stuff */
    // TODO: Not working
    
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
    
    
    
    // MARK:  - Collection View Stuff
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let message = messages[indexPath.item]
        
        // TODO: Make media logic better :/
        if message.isMediaMessage {
            if let image = MessagesViewController.imageCache.objectForKey(message.attachmentUrl!) as? UIImage {
                let photoMedia = JSQPhotoMediaItem(image: image)
                photoMedia.appliesMediaViewMaskAsOutgoing = (message.senderId == self.senderId)
                let mediaMessage = SLMessage(senderId: message.senderId, senderDisplayName: message.senderDisplayName, date: message.date, media: photoMedia, attachmentUrl: message.attachmentUrl, avatarUrl: message.avatarUrl)
                self.messages[indexPath.item] = mediaMessage
            } else {
                let url = "\(IMAGE_BASE)\(message.attachmentUrl!)"
                request?.cancel()
                request = Alamofire.request(.GET, url).validate(contentType: ["image/*"]).response(
                    completionHandler: {
                        request, response, data, err in
                        if err == nil {
                            let image = UIImage(data: data!)!
                            let photoMedia = JSQPhotoMediaItem(image: image)
                            photoMedia.appliesMediaViewMaskAsOutgoing = (message.senderId == self.senderId)
                            let mediaMessage = SLMessage(senderId: message.senderId, senderDisplayName: message.senderDisplayName, date: message.date, media: photoMedia, attachmentUrl: message.attachmentUrl, avatarUrl: message.avatarUrl)
                            MessagesViewController.imageCache.setObject(image, forKey: message.attachmentUrl!)
                            
                            self.messages[indexPath.item] = mediaMessage
                            self.collectionView?.reloadData()
                        }
                })
            }
        }
        return message
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
            setupAvatarImage(message.senderId, imageUrl: message.avatarUrl, incoming: true)
            return avatars[message.senderId]
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.textView?.textColor = SL_BLACK
        
        let attributes : [String:AnyObject] = [NSForegroundColorAttributeName: SL_GREEN, NSUnderlineStyleAttributeName: 1]
        cell.textView?.linkTextAttributes = attributes
        
        return cell
    }
    
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
        
        return NSAttributedString(string:message.senderDisplayName)
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
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            let imageInfo = JTSImageInfo()
            imageInfo.image = MessagesViewController.imageCache.objectForKey(message.attachmentUrl!) as! UIImage
            imageInfo.referenceRect = self.collectionView!.cellForItemAtIndexPath(indexPath)!.frame
            imageInfo.referenceView = self.view
            
            // Setup view controller
            let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: .Image, backgroundStyle: .Scaled)
            imageViewer.showFromViewController(self, transition: .FromOriginalPosition)
        }
    }
    
    
    
    
    /* Segue Prep */
    
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

