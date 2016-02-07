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
    @IBOutlet weak var userView: UserView!
    
    var items = [MenuItem]()
    var timer: NSTimer!
    var request: Request?
    var courseHandle: UInt!
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set Logo
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 210 , height: 70))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "studyloop-logo.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        // Tap for settings
        let tap = UITapGestureRecognizer(target: self, action: "goToSettings:")
        tap.numberOfTapsRequired = 1
        self.userView.addGestureRecognizer(tap)
        self.userView.userInteractionEnabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Watch for notifications
        Event.register(NOTIFICATION) {
            self.tableView.reloadData()
        }
        
        courseHandle = UserService.us.REF_USER_CURRENT
            .childByAppendingPath("courseIds")
            .observeEventType(.Value, withBlock: {
                snapshot in
                
                print("SNAP: ", snapshot)
                self.items.removeAll()
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    self.courseHandler(snapshots, completion: { (result) -> Void in
                        // Append Defaults
                        self.items += self.appendDefaltItems()
                        self.tableView.reloadData()
                    })
                }
                
            })
    }
    
    func courseHandler(snapshots: [FDataSnapshot], completion: (result: Bool) -> Void) {
        let currentCourse = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String
        let courseGroup = dispatch_group_create()
        
        for snap in snapshots {
            dispatch_group_enter(courseGroup)
            DataService.ds.REF_COURSES.childByAppendingPath(snap.key).observeSingleEventOfType(.Value, withBlock: { snapshot in
                let course = MenuItem(title: "\(snapshot.value.objectForKey("major")!) \(snapshot.value.objectForKey("number")!)", courseId: snapshot.value.objectForKey("id") as! String, notify: true)
                self.items.append(course)
                if course.courseId == currentCourse {
                    NSUserDefaults.standardUserDefaults().setValue(course.title, forKey: KEY_COURSE_TITLE)
                }
                dispatch_group_leave(courseGroup)
            })
        }
        
        dispatch_group_notify(courseGroup, dispatch_get_main_queue()) {
            self.items.sortInPlace {
                return $0.title < $1.title
            }
            completion(result: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if courseHandle != nil {
            UserService.us.REF_USER_CURRENT.childByAppendingPath("courseIds").removeObserverWithHandle(courseHandle)
        }
    }
    
    // MARK: - Table Stuff
    
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
            case (items.count - 1):
                // Add Course
                mainNavigation.topViewController?.performSegueWithIdentifier(SEGUE_ADD_COURSE, sender: nil)
                break
            default:
                // go to course
                NSUserDefaults.standardUserDefaults().setValue(items[indexPath.row].courseId, forKey: KEY_COURSE)
                NSUserDefaults.standardUserDefaults().setValue(items[indexPath.row].title, forKey: KEY_COURSE_TITLE)
            }
            
            tableView.reloadData()
            drawerController.setDrawerState(.Closed, animated: true)
        }
    }
    
    func appendDefaltItems() -> [MenuItem] {
        let defaults = [
            MenuItem(title: "Add Course"),
        ]
        return defaults
    }
    
    func goToSettings(sender: UITapGestureRecognizer) {
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            print("Prepare for Settings")
            let mainNavigation = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainNavigation") as! UINavigationController
            
            // go to settings / profile
            mainNavigation.topViewController?.performSegueWithIdentifier(SEGUE_SETTINGS, sender: nil)
            
            drawerController.mainViewController = mainNavigation
            drawerController.setDrawerState(.Closed, animated: true)
        }
    }
}
