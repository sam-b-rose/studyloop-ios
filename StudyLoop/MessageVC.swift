//
//  LoopVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/8/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import SlackTextViewController

protocol ModalViewControllerDelegate {
    func sendImage(var willSend : Bool, var caption : String)
}

class LoopVC: SLKTextViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ModalViewControllerDelegate {
    
    var loop: Loop!
    var messages = [Message]()
    var userImageMap = [String: String]()
    var userNameMap = [String: String]()
    var imagePicker: UIImagePickerController!
    static var imageCache = NSCache()
    
    var messagesHandle: UInt!
    var loopHandle: UInt!
    var activityHandle: UInt!
    
    var timer: NSTimer? = nil
    var imageToSend: UIImage!
    var imageName = ""
    let currentUserId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
    
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Loop Id", loop.uid)
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.inverted = false
        
        // Set up UI controls
        self.leftButton.setImage(UIImage(named: "icn_upload"), forState: UIControlState.Normal)
        self.leftButton.tintColor = SL_GRAY
        self.rightButton.setTitle("Send", forState: UIControlState.Normal)
        
        // Navbar Stuff
        let more = UIBarButtonItem(title: String.ioniconWithName(.More), style: .Plain, target: self, action: Selector("goToLoopSettings"))
        self.navigationItem.rightBarButtonItem = more
        self.navigationItem.rightBarButtonItem!.setTitleTextAttributes(attributes, forState: .Normal)
        self.navigationItem.title = loop.subject
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
        
        // Table Stuff
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 64.0
        self.tableView.separatorStyle = .None
        self.tableView.registerClass(LoopMessageCell.self, forCellReuseIdentifier: "LoopMessageCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Setup Firebase Observables */
        
        print("setting up handlers")
        
        // Get Messages
        messagesHandle = DataService.ds.REF_LOOP_MESSAGES
            .childByAppendingPath(loop.uid)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
            if let messageDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let message = Message(messageKey: key, dictionary: messageDict)
                print("Adding message: ", messageDict)
                self.addMessages(message)
            }
        })
        
        // Create User Maps
        loopHandle = DataService.ds.REF_LOOPS.childByAppendingPath(loop.uid).observeEventType(.Value, withBlock: {
            snapshot in
            if let loopDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.loop = Loop(uid: snapshot.key, loopDict: loopDict)
                self.createUserMaps({
                    result in
                    if result == true {
                        print("Finished loading user images", result)
                        self.tableView.reloadData()
                    }
                })
            }
        })
        
        // Monitor User Activity
        activityHandle = ActivityService.act.REF_ACTIVITY_LOOP.childByAppendingPath(loop.uid).observeEventType(.ChildChanged, withBlock: {
            snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.checkIfTyping(snapshot.key, user: userDict)
            }
        })
        
        // Set that user is active in loop
        ActivityService.act.REF_ACTIVITY_LOOP
            .childByAppendingPath(loop.uid)
            .childByAppendingPath(currentUserId)
            .updateChildValues([
                    "activeAt": kFirebaseServerValueTimestamp,
                    "presentAt": kFirebaseServerValueTimestamp
                ])
        
         // Set last loop for current user
        ActivityService.act.setLastLoop(loop.uid)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        // Remove Notifications
        for (key,val) in NotificationService.noti.newMessages {
            if val == loop.uid {
                NotificationService.noti.removeNotification(key)
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        print("removing handlers")
        messages.removeAll()
        
        //Remove Firebase observer handler
        DataService.ds.REF_LOOP_MESSAGES
            .childByAppendingPath(loop.uid).removeObserverWithHandle(messagesHandle)
        DataService.ds.REF_LOOPS.childByAppendingPath(loop.uid).removeObserverWithHandle(loopHandle)
        ActivityService.act.REF_ACTIVITY_LOOP.childByAppendingPath(loop.uid).removeObserverWithHandle(activityHandle)
        
        // Reset user's presence status to inactive
        ActivityService.act.REF_ACTIVITY_LOOP
            .childByAppendingPath(loop.uid)
            .childByAppendingPath(currentUserId)
            .childByAppendingPath("activeAt")
            .removeValue()
    
        ActivityService.act.REF_ACTIVITY_LOOP
            .childByAppendingPath(loop.uid)
            .childByAppendingPath(currentUserId)
            .childByAppendingPath("presentAt")
            .removeValue()
    }
    
    func createUserMaps(completion: (result: Bool)-> Void) {
        let userGroup = dispatch_group_create()
        
        for user in loop.userIds {
            dispatch_group_enter(userGroup)
            if userImageMap[user] == nil {
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
    
    
    
    // isTyping indicator helpers 
    
    override func textView(textView: SLKTextView!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
        // Watch user text input to update isTyping indicator
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateTypingIndicator:"), userInfo: textView, repeats: false)
        return true
    }
    
    func updateTypingIndicator(timer: NSTimer) {
        if let textView = timer.userInfo! as? SLKTextView {
            if textView.text != "" {
                ActivityService.act.setUserActivity(loop.uid, userId: currentUserId!, key: "typingAt", value: kFirebaseServerValueTimestamp)
            } else {
                ActivityService.act.setUserActivity(loop.uid, userId: currentUserId!, key: "typingAt", value: 0)
            }
        }
    }
    
    
    func checkIfTyping(uid: String, user: Dictionary<String, AnyObject>) {
        if currentUserId != uid {
            if let typing = user["typingAt"] as? Int where typing > 0 {
                showTypingIndicator(uid)
            } else {
                hideTypingIndicator(uid)
            }
        }
    }
    
    func detectTyping() {
        DataService.ds.REF_LOOPS.childByAppendingPath(loop.uid).childByAppendingPath("typing").observeEventType(.Value, withBlock: {
            snapshot in
            print("Is user typing: ", snapshot)
        })
    }
    
    func showTypingIndicator(uid: String) {
        if let userName = userNameMap[uid] {
            self.typingIndicatorView.insertUsername(userName)
        }
    }
    
    func hideTypingIndicator(uid: String) {
        if let userName = userNameMap[uid] {
            self.typingIndicatorView.removeUsername(userName)
        }
    }
    
    
    
    // Image Picker
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        imageName = imageURL.lastPathComponent!
        imageToSend = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        performSegueWithIdentifier(SEGUE_PREVIEW_IMAGE, sender: nil)
    }
    
    func sendImage(willSend: Bool, caption: String) {
        if willSend == true {
            let image = UIImageJPEGRepresentation(imageToSend, 0.2)
            let sizeBytes = image!.length
            if sizeBytes < 10000000 {
                let base64Image = "data:image/jpeg;base64," + image!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                let imageData: Dictionary<String, AnyObject> = [
                    "image": base64Image,
                    "size": sizeBytes,
                    "caption": caption
                ]
                sendNewMessage(imageData)
            } else {
                NotificationService.noti.showAlert("Image to Large", msg: "Image attchment is over the max 10MB limit.", uiView: self)
            }
            
        }
    }
    

    
    // Message Logic
    
    func addMessages(message: Message) {
        self.messages.append(message)
        self.messages.sortInPlace { $1.createdAt > $0.createdAt }
        
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView.reloadData()
            if self.messages.count > 0 {
                self.scrollToBottomMessage()
                // self.leftButton.setImage(UIImage(named: "icn_upload"), forState: UIControlState.Normal)
                // ActivityService.act.setUserActivity(self.loop.uid, userId: self.currentUserId!, key: "typingAt", value: 0)
            }
        }
    }
    
    func sendNewMessage(imageData: Dictionary<String, AnyObject>?) {
        ActivityService.act.setUserActivity(self.loop.uid, userId: self.currentUserId!, key: "typingAt", value: 0)
        
        var message: Dictionary<String, AnyObject> = [
            "textValue": "\(self.textView.text!)",
            "createdById": currentUserId!,
            "courseId": loop.courseId,
            "loopId": loop.uid,
            "createdAt": kFirebaseServerValueTimestamp
        ]
        
        if imageData != nil {
            let time = NSDate().timeIntervalSince1970
            let queueId: String! = "\(currentUserId!)_\(time)_\(imageName)"
            
            message["name"] = imageName
            message["dataURI"] = imageData!["image"]
            message["queueId"] = queueId
            message["sizeBytes"] = imageData!["size"]
            message["textValue"] = imageData!["caption"]
            message["type"] = "image/jpeg"
            DataService.ds.REF_QUEUES.childByAppendingPath("loop-message-attachments").childByAppendingPath("tasks").childByAutoId().setValue(message)
        } else {
            DataService.ds.REF_QUEUES.childByAppendingPath("loop-messages").childByAppendingPath("tasks").childByAutoId().setValue(message)
            DataService.ds.REF_LOOP_MESSAGES.childByAppendingPath(loop.uid).childByAutoId().setValue(message, withCompletionBlock: {
                error, ref in
                if error != nil {
                    print("Error sending message")
                } else {
                    self.textView.text = ""
                    let userName = self.userNameMap[self.currentUserId!]
                    DataService.ds.REF_LOOPS.childByAppendingPath(self.loop.uid).updateChildValues([
                        "lastMessage": "\(userName!): \(message["textValue"]!)",
                        "lastMessageTime": kFirebaseServerValueTimestamp
                        ])
                    
                }
            })
        }
    }
    
    override func didPressLeftButton(sender: AnyObject!) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        self.textView.refreshFirstResponder()
        dismissKeyboard(true)
        sendNewMessage(nil)
        super.didPressRightButton(sender)
    }
    
    
    
    // UI Logic
    
    // Scroll to bottom of table view for messages
    func scrollToBottomMessage() {
        if self.messages.count == 0 {
            return
        }
        
        let bottomMessageIndex = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1,
            inSection: 0)
        self.tableView.scrollToRowAtIndexPath(bottomMessageIndex, atScrollPosition: .Bottom,
            animated: true)
    }
    
    func goToLoopSettings() {
        performSegueWithIdentifier(SEGUE_LOOP_SETTINGS, sender: nil)
    }
    
    
    
    // UITableView Functions
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let message = messages[indexPath.row]
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("LoopMessageCell") as? LoopMessageCell {
                let imgUrl = self.userImageMap[message.createdById]
                let name = self.userNameMap[message.createdById]
                
                cell.configureCell(message.textValue, name: name, createdAt: message.createdAt, imageUrl: imgUrl, attachmentUrl: message.attachmentUrl)
                return cell
            } else {
                return MessageCell()
            }
    }
    
    
    
    // Segue Prep
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SEGUE_LOOP_SETTINGS) {
            let loopSettingsVC = segue.destinationViewController as! LoopSettingsVC
            loopSettingsVC.loopId = self.loop.uid
            loopSettingsVC.userIds = self.loop.userIds
        } else if(segue.identifier == SEGUE_PREVIEW_IMAGE) {
            let previewImageVC = segue.destinationViewController as! PreviewImageVC
            previewImageVC.delegate = self
            previewImageVC.modalPresentationStyle = .OverCurrentContext
            previewImageVC.image = self.imageToSend
        }
    }
}
