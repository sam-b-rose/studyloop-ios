//
//  SettingsVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/11/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import Alamofire
import KYDrawerController

class AppSettingsVC: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var profileImage: UserImage!
    
    var currentUser: User?
    var request: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tableView.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        // Get Current User Data
        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: {
            snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.currentUser = User(uid: snapshot.key, dictionary: userDict)
                self.nameTextField.text = self.currentUser?.name
                self.emailTextField.text = self.currentUser?.email
                self.profileImage.getImage(self.currentUser!)
            }
        })
        
        // Hide Back Nav Button text
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        request?.cancel()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print(indexPath.section, indexPath.row)
        
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 1 {
                // Logout
                print("logout")
                DataService.ds.REF_BASE.unauth()
                resetUserDefaults()
                if let drawerController = navigationController?.parentViewController as? KYDrawerController {
                    drawerController.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func resetUserDefaults() {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UNIVESITY)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE_TITLE)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        tableView.endEditing(true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SELECT_UNIVERSITY {
            let universityVC = segue.destinationViewController as? UniversityVC
            universityVC!.parentVC = "AppSettingsVC"
        }
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AppSettingsCell", forIndexPath: indexPath)
        
        if indexPath.row != 2 {
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
