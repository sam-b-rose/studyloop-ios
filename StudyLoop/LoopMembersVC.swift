//
//  LoopMembersVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/14/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class LoopMembersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var loopId: String!
    var users = [User]()
    static var imageCache = NSCache()
    
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            
            print("SNAP: \(snapshot)")
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let user = User(uid: snapshot.key, dictionary: userDict)
                self.users.append(user)
                print(self.users.count)
                self.tableView.reloadData()
            }
        })
        
        // Navbar Stuff
        navigationItem.title = "Classmates"
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
        
        // Table Stuff
        tableView.separatorStyle = .None
    }
    
    func watchLoopMembers() {
        DataService.ds.REF_LOOPS.childByAppendingPath(loopId).childByAppendingPath("userIds").observeEventType(.Value, withBlock: {
            snapshot in
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: UITableView Delegate
    // Return number of rows in the table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // Create table view rows
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let user = users[indexPath.row]
            print("USER: ", user)
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("LoopMemberCell") as? LoopMemberCell {
                cell.configureCell(user)
                return cell
            } else {
                return LoopMemberCell()
            }
    }
    
    // MARK: UITableViewDataSource Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
