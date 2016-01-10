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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // TODO: Do something with Device ID
        // let deviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
//        if let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) {
//            
//        }
        
        DataService.ds.REF_BASE.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print("From LoginVC", authData.uid)
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                
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
                        })
                    }
                    //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                })
                
            } else {
                // No user is signed in
                print("No User is signed in")
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
                        DataService.ds.REF_UID_MAPPING.childByAppendingPath(authData.uid).observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            // print(snapshot)
                            
                            if snapshot.value != nil {
                                print("Facebook User is in database")
                            } else {
                                print("No user in database")
                                self.createUser(authData, completion: {
                                    result in
                                    print(result)
                                })
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
                                    self.createUser(authData, completion: {
                                        result in
                                        print(result)
                                    })
                                })
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username and password")
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
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
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
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

