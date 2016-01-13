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
    let attributesMenu = [NSFontAttributeName: UIFont.ioniconOfSize(26)] as Dictionary!
    let attributesPlus = [NSFontAttributeName: UIFont.ioniconOfSize(18)] as Dictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(LoopCell.self, forCellReuseIdentifier: "LoopCell")
        
        // Set navigation menu title and icons
        settingBtn.setTitleTextAttributes(attributesPlus, forState: .Normal)
        settingBtn.title = String.ioniconWithName(.IosGear)
        menuBtn.setTitleTextAttributes(attributesMenu, forState: .Normal)
        menuBtn.title = String.ioniconWithName(.Navicon)
        
        if let courseTitle = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE_TITLE) as? String {
            navigationItem.title = courseTitle
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        // Load last viewed course or selected course
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String {
            noCourseLbl.hidden = true
            addLoopBtn.hidden = false
            getLoops(courseId)
        } else {
            print("No course selected")
            noCourseLbl.hidden = false
            addLoopBtn.hidden = true
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE_TITLE)
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
            cell.loopLabel.text = loop.subject
            cell.lastLabel.text = loop.lastMessage
            return cell
        } else {
            return LoopCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedLoop = loops[indexPath.row]
        if selectedLoop.hasCurrentUser == true {
            self.performSegueWithIdentifier(SEGUE_LOOP, sender: nil)
        } else {
            joinLoop()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func getLoops(courseId: String) {
        self.loops.removeAll()
        DataService.ds.REF_LOOPS
            .queryOrderedByChild("courseId")
            .queryEqualToValue(courseId)
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    // print("LOOP SNAP: ", snapshot)
                    for snap in snapshots {
                        if let loopDict = snap.value as? Dictionary<String, AnyObject> {
                            // Create Loop Object
                            let loop = Loop(uid: snap.key, loopDict: loopDict)
                            
                            // Check if user is in loop
                            let userIndex = loop.userIds.indexOf((StateService.ss.CURRENT_USER?.id)!)
                            if userIndex != nil {
                                loop.hasCurrentUser = true
                            }
                            
                            self.loops.append(loop)
                        }
                    }
                }
                self.tableView.reloadData()
            })
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
        DataService.ds.REF_LOOPS.childByAppendingPath(selectedLoop.uid).childByAppendingPath("userIds").childByAppendingPath(StateService.ss.CURRENT_USER?.id).setValue(true)
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("loopIds").childByAppendingPath(selectedLoop.uid).setValue(true)
        self.performSegueWithIdentifier(SEGUE_LOOP, sender: nil)
    }
    
    @IBAction func didTapSettingsButton(sender: AnyObject) {
        performSegueWithIdentifier(SEGUE_COURSE_SETTINGS, sender: nil)
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
