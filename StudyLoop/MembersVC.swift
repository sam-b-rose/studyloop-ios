//
//  LoopMembersVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/14/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class MembersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userIds = [String]()
    var userImageMap = [String: String]()
    var userNameMap = [String: String]()
    static var imageCache = NSCache()
    
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get user images and names
        createUserMaps { (result) -> Void in
            if result == true {
                print("finished loading users")
                self.tableView.reloadData()
            }
        }
        
        // Navbar Stuff
        navigationItem.title = "Classmates"
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
        
        // Table Stuff
        tableView.separatorStyle = .None
    }
    
    func createUserMaps(completion: (result: Bool)-> Void) {
        let userGroup = dispatch_group_create()
        
        for user in userIds {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: UITableView Delegate
    // Return number of rows in the table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIds.count
    }
    
    // Create table view rows
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let user = userIds[indexPath.row]
            let userImage = userImageMap[user]
            let userName = userNameMap[user]
            if let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell") as? MemberCell {
                cell.configureCell(userName, profileImageURL: userImage)
                return cell
            } else {
                return MemberCell()
            }
    }
    
    // MARK: UITableViewDataSource Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
