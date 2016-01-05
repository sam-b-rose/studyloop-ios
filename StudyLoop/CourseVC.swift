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
    var loops = [Loop]()
    var course = "4kZH8xslYkTLg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadCourse:", name: "reloadData", object: nil)
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
            cell.configureCell(loop)
            return cell
        } else {
            return LoopCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(SEGUE_LOOP, sender: nil)
    }
    
    func loadCourse(notification: NSNotification) {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let courseId = notification.object as? String {
            self.loops = []
            print("CourseVC", courseId)
            DataService.ds.REF_LOOPS
                .queryOrderedByChild("courseId")
                .queryEqualToValue(courseId)
                .observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        for snap in snapshots {
                            print("SNAP: \(snap)")
                            
                            if let loopDict = snap.value as? Dictionary<String, AnyObject> {
                                
                                // Create Loop Object
                                let loop = Loop(loopDict: loopDict)
                                self.loops.append(loop)
                            }
                        }
                    }
                    print("loops", self.loops.count)
                    self.tableView.reloadData()
                })
        }
    }
    
    @IBAction func didTapOpenButton(sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parentViewController as? KYDrawerController {
            drawerController.setDrawerState(.Opened, animated: true)
        }
    }
}
