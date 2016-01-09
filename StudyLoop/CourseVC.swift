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
    @IBOutlet weak var addLoopBtn: UIBarButtonItem!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    var loops = [Loop]()
    var courseTitle: String = ""
    var selectedLoop: Loop! = nil
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(22)] as Dictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(LoopCell.self, forCellReuseIdentifier: "LoopCell")
        
        // Set navigation menu title and icons
        addLoopBtn.setTitleTextAttributes(attributes, forState: .Normal)
        addLoopBtn.title = String.ioniconWithName(.PlusRound)
        menuBtn.setTitleTextAttributes(attributes, forState: .Normal)
        menuBtn.title = String.ioniconWithName(.NaviconRound)
        
        // Load last viewed course or selected course
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String {
            getLoops(courseId)
        } else {
            print("No course selected")
        }
        
        if let courseTitle = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE_TITLE) as? String {
            navigationItem.title = courseTitle
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
            print(loop.subject)
            
            cell.loopLabel.text = loop.subject
            cell.lastLabel.text = loop.lastMessage
            
            return cell
        } else {
            return LoopCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        joinLoop(loops[indexPath.row].subject)
        selectedLoop = loops[indexPath.row]
        //self.performSegueWithIdentifier(SEGUE_LOOP, sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func getLoops(courseId: String) {
        self.loops.removeAll()
        DataService.ds.REF_LOOPS
            .queryOrderedByChild("courseId")
            .queryEqualToValue(courseId)
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    for snap in snapshots {
                        if let loopDict = snap.value as? Dictionary<String, AnyObject> {
                            // Create Loop Object
                            let loop = Loop(uid: snap.key, loopDict: loopDict)
                            self.loops.append(loop)
                        }
                    }
                }
                self.tableView.reloadData()
            })
    }
    
    func joinLoop(loopName: String) {
        let alert = UIAlertController(title: "Join Loop", message: "Do you want to join \(loopName)?", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Join", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapAddCourseButton(sender: AnyObject) {
        performSegueWithIdentifier(SEGUE_ADD_LOOP, sender: nil)
    }
    
    @IBAction func didTapOpenButton(sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            drawerController.setDrawerState(.Opened, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SEGUE_LOOP) {
            let loopVC = segue.destinationViewController as! MessageVC
            loopVC.loop = selectedLoop
        }
    }
}
