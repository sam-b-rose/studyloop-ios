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
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        DataService.ds.REF_BASE.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print("From LoginVC", authData.uid, authData.providerData)
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                
                // check for university
                DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    // print(snapshot.value)
                    
                    if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                        let currentUser = User(uid: snapshot.key, dictionary: userDict)
                        StateService.ss.setUser(currentUser)
                        
                        if currentUser.universityId == nil {
                            self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
                        } else {
                            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                        }
                    } else {
                        self.showErrorAlert("No user in database", msg: "The user has been authenicated but is not in database.")
                    }
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
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (error, authData) -> Void in
                    if error != nil {
                        print("login failed. \(error)")
                        
                    } else {
                        print("Logged in! \(authData)")
                        
                        let user = [
                            "provider": authData.provider!,
                            "name": authData.providerData["displayName"] as! NSString as String,
                            "email": authData.providerData["email"] as! NSString as String,
                            "profileImageURL": authData.providerData["profileImageURL"] as! NSString as String,
                        ]
                        
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        // TODO: Check for University
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        //self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
                        //self.dismissViewControllerAnimated(true, completion: nil)
                        //self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
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
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                                    err, authData in
                                    
                                    print(authData)
                                    
                                    // TODO: should check for provider
                                    let user = [
                                        "provider": authData.provider!,
                                        "email": authData.providerData["email"] as! NSString as String,
                                        "profileImageURL": authData.providerData["profileImageURL"] as! NSString as String,
                                        "name": authData.providerData["email"] as! NSString as String
                                    ]
                                    
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                })
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username and password")
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

