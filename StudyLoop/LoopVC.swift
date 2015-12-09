//
//  LoopVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/5/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Firebase

class LoopVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var messages = [Message]()
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 432
        
        DataService.ds.REF_SINGLE_LOOP.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            
            self.messages = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let messageDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let message = Message(messageKey: key, dictionary: messageDict)
                        self.messages.append(message)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        print(message.messageText)
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        
        if message.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
