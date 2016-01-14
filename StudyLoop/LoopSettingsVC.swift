//
//  LoopSettingsVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/13/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class LoopSettingsVC: UITableViewController {

    var loopId: String?
    
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
            leaveLoop()
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName: String!
        
        switch section {
        case 0:
            sectionName = "Loop Settings"
            break
        case 1:
            sectionName = "Notifications"
            break
        default:
            sectionName = ""
        }
        
        return sectionName
    }
    
    func leaveLoop() {
        let loopTitle = "this loop"
        let alert = UIAlertController(title: "Leave Course", message: "Do you want to leave \(loopTitle)?", preferredStyle: .Alert)
        let leave = UIAlertAction(title: "Leave", style: .Default, handler: leaveLoopHandler)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let preferredAction = leave
        alert.addAction(preferredAction)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func leaveLoopHandler(alert: UIAlertAction) -> Void {
        removeUserFromLoop()
    }
    
    func removeUserFromLoop() {
        print("leave loop")
        if let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String {
            DataService.ds.REF_QUEUES.childByAppendingPath("loops").childByAppendingPath("userIds").childByAppendingPath(userId).removeValueWithCompletionBlock({
                error, ref in
                if error == nil {
                    DataService.ds.REF_USER_CURRENT.childByAppendingPath("loopIds").childByAppendingPath(self.loopId).removeValueWithCompletionBlock({
                        error, ref in
                        if error == nil {
                            print("removed user from loop")
                            self.navigationController?.popToRootViewControllerAnimated(true)
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
