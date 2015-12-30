//
//  DrawerVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/25/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import KYDrawerController

class DrawerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items = [MenuItem]()
    var request: Request?
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get course Data
        
        
        // Append Defaults
        items += appendDefaltItems()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("DrawerCell") as? DrawerCell {
            cell.configureCell(item)
            return cell
        } else {
            return DrawerCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            let mainNavigation = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainNavigation") as! UINavigationController

            switch indexPath.row {
            case (items.count - 3):
                // Settings
                print("add course")
                break
            case (items.count - 2):
                // Settings
                print("settings")
                mainNavigation.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
                break
            case (items.count - 1):
                // Logout
                print("logout")
                DataService.ds.REF_BASE.unauth()
                drawerController.performSegueWithIdentifier(SEGUE_LOGGED_OUT, sender: nil)
                break
            default:
                // go to course
                mainNavigation.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
            }
            
            // drawerController.mainViewController = mainNavigation
            drawerController.setDrawerState(.Closed, animated: true)
        }
    }
    
    func appendDefaltItems() -> [MenuItem] {
        let defaults = [
            MenuItem(title: "Add Course"),
            MenuItem(title: "Settings"),
            MenuItem(title: "Logout")
        ]
        
        return defaults
    }
    
    func goToProfile() {
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            let mainNavigation = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainNavigation") as! UINavigationController
                // go to profile
                mainNavigation.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
                drawerController.mainViewController = mainNavigation
                drawerController.setDrawerState(.Closed, animated: true)
        }
    }
    
}
