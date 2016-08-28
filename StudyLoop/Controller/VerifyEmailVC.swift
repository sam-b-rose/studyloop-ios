//
//  VerifyEmailVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 2/7/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import Firebase

class VerifyEmailVC: UITableViewController {
    
    @IBOutlet weak var verifyEmailField: UITextField!
    
    var verificationRef: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verificationRef = DataService.ds.REF_QUEUES.childByAppendingPath("user-verification-email").childByAppendingPath("tasks")
    }
    
    override func viewWillAppear(animated: Bool) {
        if UserService.us.currentUser.email.hasSuffix(".edu") {
//            verifyEmailField.text = UserService.us.currentUser.email
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string: "\(URL_VERIFY_EMAIL)\(UserService.us.currentUser.id)")!)
//                if verifyEmailField.text != "" && verifyEmailField.text!.hasSuffix(".edu") {
//                    confirmPassword()
//                } else {
//                    print(verifyEmailField.text)
//                    NotificationService.noti.showAlert("Email must be a .edu address", msg: "You must be student with a .edu email address to use StudyLoop.", uiView: self)
//                }
            } else if indexPath.row == 1 {
                leaveVC()
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func verifyEmail() {
        verificationRef.childByAutoId().setValue(["userId": UserService.us.currentUser.id]) {
            error, ref in
            if error == nil {
                self.showAlert()
            } else {
                print("failed to send verification email")
            }
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Verification Sent", message: "A verification email has been sent! Check your inbox and verify your .edu email address.", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "Ok", style: .Default, handler: {
            (UIAlertAction) -> Void in
            self.leaveVC()
        })
        
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func confirmPassword() {
        let alert = UIAlertController(title: "Confirm Password", message: "Please retype your password", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        })
        
        let enter = UIAlertAction(title: "Enter", style: .Default)  {
            _ in
            
            let pass = alert.textFields![0]
            UserService.us.REF_USER_CURRENT.changeEmailForUser(UserService.us.currentUser.email, password: pass.text, toNewEmail: self.verifyEmailField.text, withCompletionBlock: {
                error in
                if error == nil {
                    self.verifyEmail()
                } else {
                    print(error)
                    self.leaveVC()
                }
            })
        }
        
        let forgot = UIAlertAction(title: "Forgot", style: .Cancel, handler: {
            _ in
            self.leaveVC()
        })
        
        alert.addAction(enter)
        alert.addAction(forgot)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func leaveVC() {
        print("unwinding")
        DataService.ds.REF_BASE.unauth()
        self.performSegueWithIdentifier("unwindToInit", sender: self)
    }
}
