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

class LoopVC: SLKTextViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var loop: Loop!
    var messages = [Message]()
    var userImageMap = [String: String]()
    var userNameMap = [String: String]()
    var imagePicker: UIImagePickerController!
    static var imageCache = NSCache()
    
    var timer: NSTimer? = nil
    var imageToSend: UIImage!
    var imageSelected = false
    let currentUserId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
    
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.inverted = false
        
        // Get Loop Data
        self.loadMessages()
        
        // Watch Loop
        self.watchLoop()
        
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
        
        // Monitor User Activity
        ActivityService.act.REF_LOOP.childByAppendingPath(loop.uid).observeEventType(.ChildChanged, withBlock: {
            snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.checkIfTyping(snapshot.key, user: userDict)
            }
        })
        
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelected = true
        imageToSend = image
        performSegueWithIdentifier(SEGUE_PREVIEW_IMAGE, sender: nil)
    }
    
    func showModal() {
        let previewImageVC = PreviewImageVC()
        previewImageVC.modalPresentationStyle = .OverCurrentContext
        presentViewController(previewImageVC, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    override func textView(textView: SLKTextView!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
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
    
    func watchLoop() {
        DataService.ds.REF_LOOPS.childByAppendingPath(loop.uid).observeEventType(.Value, withBlock: {
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
    
    // MARK: Message Logic
    func loadMessages() {
        self.messages.removeAll()
        // Get Messages
        DataService.ds.REF_LOOP_MESSAGES.childByAppendingPath(loop.uid).observeEventType(.ChildAdded, withBlock: { snapshot in
            if let messageDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let message = Message(messageKey: key, dictionary: messageDict)
                self.addMessages(message)
            }
        })
    }
    
    func addMessages(message: Message) {
        self.messages.append(message)
        self.messages.sortInPlace { $1.createdAt > $0.createdAt }
        
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView.reloadData()
            if self.messages.count > 0 {
                self.scrollToBottomMessage()
                self.leftButton.setImage(UIImage(named: "icn_upload"), forState: UIControlState.Normal)
                ActivityService.act.setUserActivity(self.loop.uid, userId: self.currentUserId!, key: "typingAt", value: 0)
            }
        }
    }
    
    override func didPressLeftButton(sender: AnyObject!) {
        print("Select Image")
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        self.textView.refreshFirstResponder()
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        
        if let _ = imageToSend where imageSelected == true {
            print("Send Image")
        }
        
        let message: Dictionary<String, AnyObject> = [
            "textValue": "\(self.textView.text!)",
            "createdById": userId!,
            "courseId": loop.courseId,
            "loopId": loop.uid,
            "createdAt": kFirebaseServerValueTimestamp
        ]
        
        DataService.ds.REF_QUEUES.childByAppendingPath("loop-messages").childByAppendingPath("tasks").childByAutoId().setValue(message)
        DataService.ds.REF_LOOP_MESSAGES.childByAppendingPath(loop.uid).childByAutoId().setValue(message, withCompletionBlock: {
            error, ref in
            if error != nil {
                print("Error sending message")
            } else {
                self.textView.text = ""
                // DataService.ds.REF_LOOPS.childByAppendingPath(self.loop.uid).setValue(["lastMessage" : message])
            }
        })
        super.didPressRightButton(sender)
    }
    
    // MARK: UI Logic
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
    
    func detectTyping() {
        DataService.ds.REF_LOOPS.childByAppendingPath(loop.uid).childByAppendingPath("typing").observeEventType(.Value, withBlock: {
            snapshot in
            print(snapshot)
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
    
    func goToLoopSettings() {
        performSegueWithIdentifier(SEGUE_LOOP_SETTINGS, sender: nil)
    }
    
    // MARK: UITableView Delegate
    // Return number of rows in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let message = messages[indexPath.row]
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("LoopMessageCell") as? LoopMessageCell {
                let imgUrl = self.userImageMap[message.createdById]
                let name = self.userNameMap[message.createdById]
                
                cell.configureCell(message.textValue, name: name, imageUrl: imgUrl)
                return cell
            } else {
                return MessageCell()
            }
    }
    
    // MARK: UITableViewDataSource Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SEGUE_LOOP_SETTINGS) {
            let loopSettingsVC = segue.destinationViewController as! LoopSettingsVC
            loopSettingsVC.loopId = self.loop.uid
            loopSettingsVC.userIds = self.loop.userIds
        } else if(segue.identifier == SEGUE_PREVIEW_IMAGE) {
            let previewImageVC = segue.destinationViewController as! PreviewImageVC
            previewImageVC.image = self.imageToSend
        }
    }
}
