//
//  MessageVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/8/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import SlackTextViewController

class MessageVC: SLKTextViewController {
    
    var loop: Loop!
    var messages = [Message]()
    var userImageMap = [String: String]()
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.pleaseWait()
        
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
        self.leftButton.tintColor = UIColor.grayColor()
        self.rightButton.setTitle("Send", forState: UIControlState.Normal)
        navigationItem.title = loop.subject
        
        // Table Stuff
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 64.0
        self.tableView.separatorStyle = .None
        self.tableView.registerClass(LoopMessageCell.self, forCellReuseIdentifier: "LoopMessageCell")
    }
    
    func watchLoop() {
        DataService.ds.REF_LOOPS.childByAppendingPath(loop.uid).observeEventType(.Value, withBlock: {
            snapshot in
            if let loopDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.loop = Loop(uid: snapshot.key, loopDict: loopDict)
                self.mapUserImages({
                    result in
                    if result == true {
                        self.tableView.reloadData()
                        // self.clearAllNotice()
                    }
                })
            }
        })
    }
    
    func mapUserImages(completion: (result: Bool)-> Void) {
        let userGroup = dispatch_group_create()
        
        for user in loop.userIds {
        dispatch_group_enter(userGroup)
            if userImageMap[user] == nil {
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
                // Slacks Scroll
                // self.tableView.slk_scrollToBottomAnimated(true)
            }
        }
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        self.textView.refreshFirstResponder()
        
        let message: Dictionary<String, AnyObject> = [
            "textValue": "\(self.textView.text!)",
            "createdById": (StateService.ss.CURRENT_USER?.id)!,
            "createdByName": (StateService.ss.CURRENT_USER?.name)!,
            "courseId": loop.courseId,
            "loopId": loop.uid,
            "createdAt": kFirebaseServerValueTimestamp
        ]
        
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
    
    func showTypingIndicator(member: String) {
        self.typingIndicatorView.insertUsername(member)
    }
    
    func hideTypingIndicator(member: String) {
        self.typingIndicatorView.removeUsername(member)
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
                cell.configureCell(message.textValue, name: message.createdByName, imageUrl: imgUrl)
                return cell
            } else {
                return MessageCell()
            }
    }
    
    // MARK: UITableViewDataSource Delegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
}
