//
//  ViewController.swift
//  StudyLoop
//
//  Created by Sam Rose on 11/28/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var handle: UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Do something with Device ID
        // let deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        handle = DataService.ds.REF_BASE.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print("From LoginVC", authData.uid)
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
                NSUserDefaults.standardUserDefaults().setValue("Select a Course", forKey: KEY_COURSE_TITLE)
                self.checkUserData(authData)
            } else {
                // No user is signed in
                print("No User is signed in")
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        print("Removing Auth Observer")
        DataService.ds.REF_BASE.removeAuthEventObserverWithHandle(handle!)
    }
    
    
    func checkUserData(authData: FAuthData) {
        // check for if user exists and if they have a university selected
        DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let currentUser = User(uid: snapshot.key, dictionary: userDict)
                StateService.ss.setUser(currentUser)
                
                if currentUser.universityId == nil {
                    self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(currentUser.universityId, forKey: KEY_UNIVESITY)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            } else {
                print("No user in database")
                self.createUser(authData, completion: {
                    result in
                    print(result)
                    self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
                })
            }
        })
        
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler: { (facebookResutl: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                //print("Successfully logined in with facebook. \(accessToken)")
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: {
                    error, authData in
                    if error != nil {
                        print("login failed. \(error)")
                    } else {
                        print("Logged in!")
                        
                        // Check UID Mapping
                        DataService.ds.REF_UID_MAPPING.childByAppendingPath(authData.uid).observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            if snapshot.value != nil {
                                print("Facebook User is in database")
                            } else {
                                print("No user in database")
                            }
                        })
                    }
                })
            }
        })
    }
    
    @IBAction func attempLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    print(error)
                    print(error.code)
                    
                    if error.code == STATUS_ACCOUNT_NONEXSIT {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating accound. Try something else")
                            } else {
                                print("Created a new email/password user!")
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                                    error, authData in
                                    // create new user - handled in checkUserData
                                })
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username and password")
                    }
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
    }
    
    func createUser(authData: FAuthData, completion: (result: String) -> Void) {
        DataService.ds.REF_UID_MAPPING.childByAppendingPath(authData.uid).setValue(authData.uid, withCompletionBlock: {
            error, ref in
            if error != nil {
                print("Error setting the UID Mapping")
            } else {
                let name = (authData.providerData["displayName"] != nil) ? authData.providerData["displayName"] : authData.providerData["email"]
                let user = [
                    "id": authData.uid as String,
                    "name": name as! NSString as String,
                    "email": authData.providerData["email"] as! NSString as String,
                    "profileImageURL": authData.providerData["profileImageURL"] as! NSString as String,
                ]
                
                DataService.ds.createFirebaseUser(authData.uid, user: user)
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
//                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
//                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE_TITLE)
//                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UNIVESITY)
                completion(result: "Finished creating user")
            }
        })
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

