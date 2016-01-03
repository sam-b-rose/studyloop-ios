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
        
        // Set Logo
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 210 , height: 60))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "studyloop-logo.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "getUsersCourses:",name:"loadCourses", object: nil)
        
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("courseIds").observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            
            self.items = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: ", snap)
                    DataService.ds.REF_COURSES.childByAppendingPath(snap.key).observeSingleEventOfType(.Value, withBlock: { snapshot in
                        print(snapshot)
                        let course = MenuItem(title: "\(snapshot.value.objectForKey("major")!) \(snapshot.value.objectForKey("number")!)", borderTop: false)
                        print(course.title)
                        self.items.insert(course, atIndex: 0)
                        
                        self.tableView.reloadData()
                    })
                }
            }
            
            // Append Defaults
            self.items += self.appendDefaltItems()
            
            self.tableView.reloadData()
        })
        
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
            drawerController.mainViewController = mainNavigation
            
            switch indexPath.row {
            case (items.count - 3):
                // Settings
                print("add course")
                mainNavigation.topViewController?.performSegueWithIdentifier(SEGUE_ADD_COURSE, sender: nil)
                break
            case (items.count - 2):
                // Settings
                print("settings")
                mainNavigation.topViewController?.performSegueWithIdentifier(SEGUE_SETTINGS, sender: nil)
                break
            case (items.count - 1):
                // Logout
                print("logout")
                DataService.ds.REF_BASE.unauth()
                drawerController.dismissViewControllerAnimated(true, completion: nil)
                break
            default:
                // go to course
                mainNavigation.topViewController?.viewDidAppear(false)
            }
            
            // drawerController.mainViewController = mainNavigation
            drawerController.setDrawerState(.Closed, animated: true)
        }
    }
    
    func appendDefaltItems() -> [MenuItem] {
        let defaults = [
            MenuItem(title: "Add Course"),
            MenuItem(title: "Settings", borderTop: true),
            MenuItem(title: "Logout")
        ]
        print("appended defaults")
        
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
    
//    func getUsersCourses() {
//        for (courseId, val) in (StateService.ss.CURRENT_USER?.courseIds)! {
//            if val == 1 {
//                DataService.ds.REF_COURSES.childByAppendingPath(courseId).observeSingleEventOfType(.Value, withBlock: { snapshot in
//                    // print(snapshot)
//                    let course = MenuItem(title: "\(snapshot.value.objectForKey("major")!) \(snapshot.value.objectForKey("number")!)", borderTop: false)
//                    print(course.title)
//                    self.items.insert(course, atIndex: 0)
//                    
//                    self.tableView.reloadData()
//                })
//            }
//        }
//    }
    
}
