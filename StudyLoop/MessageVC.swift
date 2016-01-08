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
    var lastSeen: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.inverted = false
        
        // Get Loop Data
        self.loadMessages()
        
        // Set up UI controls
        self.leftButton.setImage(UIImage(named: "icn_upload"), forState: UIControlState.Normal)
        self.leftButton.tintColor = UIColor.grayColor()
        self.rightButton.setTitle("Send", forState: UIControlState.Normal)
        
        // Table Stuff
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 64.0
        self.tableView.separatorStyle = .None
        self.tableView.registerClass(LoopMessageCell.self, forCellReuseIdentifier: "LoopMessageCell")
    }
    
    // MARK: Message Logic
    func loadMessages() {
        self.messages.removeAll()
        
        // Get Messages
        print("Loop ID", loop.uid)
        DataService.ds.REF_LOOP_MESSAGES.childByAppendingPath(loop.uid).observeEventType(.Value, withBlock: { snapshot in
            var messages = [Message]()
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let messageDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let message = Message(messageKey: key, dictionary: messageDict)
                        messages.append(message)
                    }
                }
            }
            self.addMessages(messages)
        })
    }
    
    func addMessages(messages: [Message]) {
        // self.messages.appendContentsOf(messages)
        // self.messages.sortInPlace { $1.createdAt > $0.createdAt }
        self.messages = messages
        
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView.reloadData()
            if self.messages.count > 0 {
                self.scrollToBottomMessage()
            }
            //DataService.ds.REF_USER_CURRENT.childByAppendingPath("loopIds").childByAppendingPath(self.loop.uid).setValue([".sv": "timestamp"])
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
//        self.tableView.slk_scrollToBottomAnimated(true)
        let bottomMessageIndex = NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0) - 1,
            inSection: 0)
        self.tableView.scrollToRowAtIndexPath(bottomMessageIndex, atScrollPosition: .Bottom,
            animated: true)
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
                
                cell.nameLabel.text = message.createdByName
                cell.bodyLabel.text = message.textValue
                cell.selectionStyle = .None
                
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
