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

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
//            let currentUser = DataService.ds.REF_USER_CURRENT
//            
//            currentUser.observeSingleEventOfType(.Value, withBlock: { snapshot in
//                print(snapshot.value)
//                
//                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
//                    for snap in snapshots {
//                        print("SNAP: \(snap)")
//                        
//                        if let key = snap.key where key == "universityId" {
//                            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
//                        }
//                    }
//                    self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
//                }
//            })
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: Remove after done testing auth
        DataService.ds.REF_BASE.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print(authData.providerData)
                
                // check for university
                let currentUser = DataService.ds.REF_USER_CURRENT
                
                currentUser.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    print(snapshot.value)
                    
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        for snap in snapshots {
                            print("SNAP: \(snap)")
                            
                            if let key = snap.key where key == "universityId" {
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                        }
                        self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
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
                print("Successfully logined in with facebook. \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (error, authData) -> Void in
                    if error != nil {
                        print("login failed. \(error)")
                        
                    } else {
                        print("Logged in! \(authData)")
                        
                        // TODO: should check for provider
                        let user = [
                            "provider": authData.provider!,
                            "name": authData.providerData["displayName"] as! NSString as String,
                            "email": authData.providerData["email"] as! NSString as String,
                            "profileImgURL": authData.providerData["profileImageURL"] as! NSString as String
                        ]
                        
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        })
    }
    
    @IBAction func attempLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
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
                                        "profileImgURL": authData.providerData["profileImageURL"] as! NSString as String,
                                        "name": authData.providerData["email"] as! NSString as String
                                    ]
                                    
                                    // let newUser = User(newUser: user)
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_SELECT_UNIVERSITY, sender: nil)
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username and password")
                    }
                }
                
//                else {
//                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
//                }
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

