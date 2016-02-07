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
        UserService.us.REF_USER_CURRENT.observeEventType(.Value, withBlock: {
            snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.currentUser = User(uid: snapshot.key, dictionary: userDict)
                self.nameTextField.text = self.currentUser?.name
                self.emailTextField.text = self.currentUser?.email
                self.profileImage.getImage(self.currentUser!)
                
                if self.currentUser?.provider == "facebook" {
                    self.emailTextField.userInteractionEnabled = false
                }
                
                DataService.ds.REF_UNIVERSITIES.childByAppendingPath(self.currentUser?.universityId).observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                    if let universityDict = snapshot.value as? Dictionary<String, AnyObject> {
                        self.universityLabel.text = universityDict["shortName"] as? String
                    }
                })
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 3 {
                performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
            } else if indexPath.row == 4 {
                performSegueWithIdentifier(SEGUE_CHANGE_PWD, sender: nil)
            } else if indexPath.row == 5 {
                saveUserInfo()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                NotificationService.noti.removeAllNotifications()
            } else if indexPath.row == 2 {
                // Logout
                print("logout")
                logoutUser()
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                showDeleteConfirmation()
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func resetUserDefaults() {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE_TITLE)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        tableView.endEditing(true)
    }
    
    func logoutUser() {
        NotificationService.noti.removeNotificationObserver()
        DataService.ds.REF_BASE.unauth()
        resetUserDefaults()
        self.performSegueWithIdentifier("unwindToInit", sender: nil)
    }
    
    func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        })
        
        let delete = UIAlertAction(title: "Delete", style: .Default)  {
            _ in
            
            let pass = alert.textFields![0]
            UserService.us.REF_USER_CURRENT.removeValueWithCompletionBlock({
                error, ref in
                
                if error == nil {
                    DataService.ds.REF_BASE.removeUser(self.currentUser?.email, password: pass.text) {
                        error in
                        
                        if error == nil {
                            DataService.ds.REF_BASE.unauth()
                            self.resetUserDefaults()
                            if let drawerController = self.navigationController?.parentViewController as? KYDrawerController {
                                drawerController.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                    }
                } else {
                    print(error)
                }
            })
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let preferredAction = cancel
        
        alert.addAction(delete)
        alert.addAction(preferredAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveUserInfo() {
        if let name = nameTextField.text where name != "",
            let email = emailTextField.text where email != "" {
                let user: Dictionary<String, AnyObject> = [
                    "updatedAt": kFirebaseServerValueTimestamp,
                    "email": email,
                    "name": name
                ]
                
                UserService.us.REF_USER_CURRENT.updateChildValues(user, withCompletionBlock: {
                    error, ref in
                    if error == nil {
                        NotificationService.noti.success("Profile has been updated.")
                    }
                })
        }
    }
    
    
    
    // MARK: - Segue Prep
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SELECT_UNIVERSITY {
            let universityVC = segue.destinationViewController as? UniversityVC
            universityVC!.previousVC = "AppSettingsVC"
        } else if segue.identifier == SEGUE_CHANGE_PWD {
            let changePasswordVC = segue.destinationViewController as? ChangePasswordVC
            changePasswordVC!.previousVC = "AppSettingsVC"
        }
    }
}
