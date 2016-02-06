//
//    } CourseSettingsVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/12/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import MPGNotification

class CourseSettingsVC: UITableViewController {
    
    var userIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let courseId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE) as? String {
            DataService.ds.REF_COURSES.childByAppendingPath(courseId).childByAppendingPath("userIds").observeEventType(.Value, withBlock: {
                snapshot in
                if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                    for (key, _) in userDict {
                        self.userIds.append(key)
                    }
                }
            })
        }
        
        // Hide the Back Navigation button text
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                performSegueWithIdentifier(SEGUE_MEMBERS, sender: nil)
            }
            
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
                    UserService.us.REF_USER_CURRENT.childByAppendingPath("courseIds").childByAppendingPath(courseId).removeValueWithCompletionBlock({
                        error, ref in
                        if error == nil {
                            let courseTitle = NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE_TITLE) as? String
                            NotificationService.noti.success("You have been removed from \(courseTitle!).")
                            
                            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
                            NSUserDefaults.standardUserDefaults().setValue("Select a Course", forKey: KEY_COURSE_TITLE)
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            NotificationService.noti.error()
                        }
                    })
                } else {
                    NotificationService.noti.error()
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == SEGUE_MEMBERS && self.userIds.count > 0) {
            let membersVC = segue.destinationViewController as! MembersVC
            membersVC.userIds = userIds
        }
    }
    
    
    @IBAction func notificationValueChanged(sender: UISwitch) {
        UserService.us.setMuteCourse(sender.on)
        print(sender.on)
    }
    
}
