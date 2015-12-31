//
//  AddCourseVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/30/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class AddCourseVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var courses = [MenuItem]()
    var courseResults = [MenuItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get Course Data
        if(StateService.ss.COURSES?.count == 0) {
            StateService.ss.getCourses()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let course = courses[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("DrawerCell") as? DrawerCell {
            cell.configureCell(course)
            return cell
        } else {
            return DrawerCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Add Course to User
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
