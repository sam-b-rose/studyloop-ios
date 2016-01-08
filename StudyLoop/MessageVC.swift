//
//  MessageVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/8/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import SlackTextViewController

class MessageVC: SLKTextViewController {
    
    var loop: Loop!
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get Loop Data

        // Table Stuff
        // Set up UI controls
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 64.0
        self.tableView.separatorStyle = .None
    }
    
    // MARK: Message Logic
    func loadMessages() {
        self.messages.removeAll()
        // Get Messages
        let messages = [Message]()
        self.addMessages(messages)
    }
    
    func addMessages(messages: [Message]) {
        self.messages.appendContentsOf(messages)
        self.messages.sortInPlace { $1.createdAt > $0.createdAt }
        
        dispatch_async(dispatch_get_main_queue()) {
            () -> Void in
            self.tableView.reloadData()
            if self.messages.count > 0 {
                self.scrollToBottomMessage()
            }
        }
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
    
    // MARK: UITableView Delegate
    // Return number of rows in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // Create table view rows
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let message = messages[indexPath.row]
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as? MessageCell {
                
                cell.request?.cancel()
                
                var img: UIImage?
                
                if let url =  message.imageUrl {
                    img = LoopVC.imageCache.objectForKey(url) as? UIImage
                }
                
                cell.configureCell(message, img: img)
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
