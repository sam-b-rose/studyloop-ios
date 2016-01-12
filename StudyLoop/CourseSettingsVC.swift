//
//    } CourseSettingsVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/12/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class CourseSettingsVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Hide the Back Navigation button text
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 1 {
            leaveCourse()
        }
    }
    
    func leaveCourse() {
        let courseTitle = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE_TITLE)!
        let alert = UIAlertController(title: "Leave Course", message: "Do you want to leave \(courseTitle)?", preferredStyle: .Alert)
        let join = UIAlertAction(title: "Leave", style: .Default, handler: leaveCourseHandler)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let preferredAction = join
        alert.addAction(preferredAction)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }

    func leaveCourseHandler(alert: UIAlertAction) -> Void {
        removeUserFromCourse()
    }
    
    func removeUserFromCourse() {
        print("leave course")
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String {
            DataService.ds.REF_USER_CURRENT.childByAppendingPath("courseIds").childByAppendingPath(courseId).removeValue()
            print("removed course from user")
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    
    // Configure the cell...
    
    return cell
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
}
