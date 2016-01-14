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
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                leaveCourse()
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName: String!
        
        switch section {
        case 0:
            let courseTitle = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE_TITLE) as? String
            sectionName = "\(courseTitle!) Settings"
            break
        case 1:
            sectionName = "Notifications"
            break
        default:
            sectionName = ""
        }
        
        return sectionName
    }
    
    func leaveCourse() {
        let courseTitle = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE_TITLE)!
        let alert = UIAlertController(title: "Leave Course", message: "Do you want to leave \(courseTitle)?", preferredStyle: .Alert)
        let leave = UIAlertAction(title: "Leave", style: .Default, handler: leaveCourseHandler)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let preferredAction = leave
        alert.addAction(preferredAction)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func leaveCourseHandler(alert: UIAlertAction) -> Void {
        removeUserFromCourse()
    }
    
    func removeUserFromCourse() {
        print("leave course")
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String, let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String {
            DataService.ds.REF_COURSES.childByAppendingPath(courseId).childByAppendingPath("userIds").childByAppendingPath(userId).removeValueWithCompletionBlock({
                error,  ref in
                if error == nil {
                    DataService.ds.REF_USER_CURRENT.childByAppendingPath("courseIds").childByAppendingPath(courseId).removeValueWithCompletionBlock({
                        error, ref in
                        if error == nil {
                            self.noticeSuccess("Success!", autoClear: true, autoClearTime: 2)
                            // refresh CourseVC page
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            self.noticeError("Error!", autoClear: true, autoClearTime: 2)
                        }
                    })
                } else {
                    self.noticeError("Error!", autoClear: true, autoClearTime: 2)
                }
            })
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("courseSettingsCell", forIndexPath: indexPath)
        
        if indexPath.row != 1 {
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
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
