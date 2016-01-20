//
//  ChangePasswordVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/20/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class ChangePasswordVC: UITableViewController {
    
    @IBOutlet weak var oldPwdField: UITextField!
    @IBOutlet weak var newPwdField: UITextField!
    @IBOutlet weak var newPwdFieldConfirm: UITextField!
    
    var previousVC: String!
    var userEmail: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the Back Navigation button text
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                changePassword()
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func changePassword() {
        if let oldPwd = oldPwdField.text where oldPwd != "",
            let newPwd = newPwdField.text where newPwd != "",
            let newPwdConf = newPwdFieldConfirm.text where newPwdConf != "" {
                if newPwd == newPwdConf {
                    DataService.ds.REF_BASE.changePasswordForUser(userEmail, fromOld: oldPwd, toNew: newPwd) {
                        error in
                        if error == nil {
                            NotificationService.noti.success("Password has been changed.")
                            DataService.ds.REF_BASE.authUser(self.userEmail, password: newPwd, withCompletionBlock: { error, authData in
                                // user authed again to update isTemporaryPassword
                                if self.previousVC == "LoginVC" {
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                } else if self.previousVC == "AppSettingsVC" {
                                    self.navigationController?.popViewControllerAnimated(true)
                                }
                            })
                        } else {
                            print(error)
                            self.showAlert("Incorrect password", msg: "Old password was incorrect.")
                        }
                    }
                } else {
                    showAlert("Password doesn't match", msg: "Make sure your new password is the same for both fields.")
                }
        } else {
            self.showAlert("Not complete", msg: "Make sure to fill out every field.")
        }
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
