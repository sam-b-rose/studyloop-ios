//
//  CourseVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/2/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import KYDrawerController

class CourseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingBtn: UIBarButtonItem!
    @IBOutlet weak var addLoopBtn: MaterialButton!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    @IBOutlet weak var noCourseLbl: UILabel!
    
    var loops = [Loop]()
    var selectedLoop: Loop! = nil
    var handle: UInt!
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(LoopCell.self, forCellReuseIdentifier: "LoopCell")
        
        // Set Add Loop Icon
        addLoopBtn.titleLabel?.font = UIFont.ioniconOfSize(38)
        addLoopBtn.setTitle(String.ioniconWithName(.Plus), forState: .Normal)
        
        // Set navigation menu title and icons
        settingBtn.setTitleTextAttributes(attributes, forState: .Normal)
        settingBtn.title = ""
        menuBtn.setTitleTextAttributes(attributes, forState: .Normal)
        menuBtn.title = String.ioniconWithName(.Navicon)
        
        // Table
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.separatorStyle = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        // Load last viewed course or selected course
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String {
            noCourseLbl.hidden = true
            addLoopBtn.hidden = false
            settingBtn.title = String.ioniconWithName(.More)
            ActivityService.act.setLastCourse(courseId)
            
            // Get Loops in Course
            handle = DataService.ds.REF_LOOPS
                .queryOrderedByChild("courseId")
                .queryEqualToValue(courseId)
                .observeEventType(.Value, withBlock: {
                    snapshot in
                    
                    // Clear current loops
                    self.loops.removeAll()
                    
                    // Add new set of loops
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        for snap in snapshots {
                            if let loopDict = snap.value as? Dictionary<String, AnyObject> {
                                
                                // Create Loop Object
                                let loop = Loop(uid: snap.key, loopDict: loopDict)
                                
                                // Check if user is in loop
                                let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
                                let userIndex = loop.userIds.indexOf((userId)!)
                                if userIndex != nil {
                                    loop.hasCurrentUser = true
                                }
                                self.loops.append(loop)
                            }
                        }
                    }
                    
                    self.loops.sortInPlace {
                        return $0.createdAt > $1.createdAt
                    }
                    
                    self.tableView.reloadData()
                })
        } else {
            loops.removeAll()
            tableView.reloadData()
            noCourseLbl.hidden = false
            addLoopBtn.hidden = true
            settingBtn.title = ""
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE_TITLE)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // Watch for notifications for Courses
        Event.register(EVENT_NEW_MESSAGE) {
            self.tableView.reloadData()
        }
        
        Event.register(EVENT_NEW_LOOP) {
            // do something to reload course loops
        }
        
        if let courseTitle = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE_TITLE) as? String {
            navigationItem.title = courseTitle
        } else {
            navigationItem.title = "Select a Course"
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        //Remove Firebase observer handler
        DataService.ds.REF_BASE.removeObserverWithHandle(handle)
        
        // Remove Notifications about this course
        let loopIds = loops.map { $0.uid }
        for(key, val) in NotificationService.noti.newLoops {
            if loopIds.indexOf(val) != nil {
                NotificationService.noti.removeNotification(key)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loops.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let loop = loops[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("LoopCell") as? LoopCell {
            cell.configureCell(loop)
            return cell
        }
        return LoopCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row < loops.count && loops.count > 0 {
            selectedLoop = loops[indexPath.row]
            
            if selectedLoop.hasCurrentUser == true {
                self.performSegueWithIdentifier(SEGUE_LOOP, sender: nil)
            } else {
                joinLoop()
            }
        } else {
            print("Selected row index is out of range. Selected \(indexPath.row) and only \(loops.count) in Loops)")
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func joinLoop() {
        let alert = UIAlertController(title: "Join Loop", message: "Do you want to join \(selectedLoop.subject)?", preferredStyle: .Alert)
        let join = UIAlertAction(title: "Join", style: .Default, handler: joinLoopHandler)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let preferredAction = join
        alert.addAction(preferredAction)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func joinLoopHandler(alert: UIAlertAction) -> Void {
        addUserToLoop()
    }
    
    func addUserToLoop() {
        let currentUser = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        DataService.ds.REF_LOOPS.childByAppendingPath(selectedLoop.uid).childByAppendingPath("userIds").childByAppendingPath(currentUser).setValue(true)
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("loopIds").childByAppendingPath(selectedLoop.uid).setValue(true)
        self.performSegueWithIdentifier(SEGUE_LOOP, sender: nil)
    }
    
    @IBAction func didTapSettingsButton(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) != nil {
            performSegueWithIdentifier(SEGUE_COURSE_SETTINGS, sender: nil)
        }
    }
    
    @IBAction func didTapAddLoopButton(sender: AnyObject) {
        performSegueWithIdentifier(SEGUE_ADD_LOOP, sender: nil)
    }
    
    @IBAction func didTapOpenButton(sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            drawerController.setDrawerState(.Opened, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SEGUE_LOOP) {
            let loopVC = segue.destinationViewController as! LoopVC
            loopVC.loop = selectedLoop
        }
    }
}
