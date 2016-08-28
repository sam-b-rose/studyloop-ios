//
//  LoopSettingsVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/13/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import MPGNotification

class LoopSettingsVC: UITableViewController {
    
    var loop: Loop!
    var userIds: [String]?
    @IBOutlet weak var muteLoopSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the Back Navigation button text
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
        
        // Set up listener for mute switch
        muteLoopSwitch.addTarget(self, action: Selector("muteToggled:"), forControlEvents: .ValueChanged)
        
        // Set up UI for mute switch
        if let muted = loop.muted {
            muteLoopSwitch.on = muted
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch(indexPath.section, indexPath.row) {
        case (0, 0):
            performSegueWithIdentifier(SEGUE_MEMBERS, sender: nil)
        case (0, 1):
            self.leaveLoop()
        default:
            break
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
        let alert = UIAlertController(title: "Leave Loop", message: "Do you want to leave \(loopTitle)?", preferredStyle: .Alert)
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
            DataService.ds.REF_LOOPS
                .childByAppendingPath(loop.uid)
                .childByAppendingPath("userIds")
                .childByAppendingPath(userId)
                .removeValueWithCompletionBlock({
                    error, ref in
                    if error == nil {
                        UserService.us.REF_USER_CURRENT
                            .childByAppendingPath("loopIds")
                            .childByAppendingPath(self.loop.uid)
                            .removeValueWithCompletionBlock({
                                error, ref in
                                if error == nil {
                                    NotificationService.noti.success("You have been removed from the loop.")
                                    
                                    self.navigationController?.popToRootViewControllerAnimated(true)
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
    
    func showError() {
        let notification = MPGNotification(title: "Error!", subtitle: "Failed to leave course.", backgroundColor: SL_RED, iconImage: nil)
        notification.swipeToDismissEnabled = false
        notification.duration = 2
        notification.show()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SEGUE_MEMBERS && self.userIds != nil) {
            let loopMembersVC = segue.destinationViewController as! MembersVC
            loopMembersVC.userIds = self.userIds!
        }
    }
    
    func muteToggled(sender: UISwitch) {
        UserService.us.setMuteLoop(loop.uid, isMuted: sender.on)
        self.loop.muted = !self.loop.muted
        print("Mute Toggle State: \(sender.on)")
    }
}
