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

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    var handle: UInt?
    var isRegistering = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide name field initially
        hideNameFields()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
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
                self.updateProfilePicture(authData)
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
    
    
    
    // VIEW HELPERS
    
    func hideNameFields() {
        titleLbl.text = "Login"
        nameField.frame.size.height = 0
        nameField.hidden = true
        loginBtn.setTitle("Login", forState: .Normal)
        registerBtn.setTitle("Not registered? Sign up!", forState: .Normal)
    }
    
    func showNameFields() {
        titleLbl.text = "Register"
        nameField.frame.size.height = 35
        nameField.hidden = false
        loginBtn.setTitle("Register", forState: .Normal)
        registerBtn.setTitle("Already have an account? Login!", forState: .Normal)

    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    // DATA LOGIC
    
    func updateProfilePicture(authData: FAuthData) {
        if let imageUrl = authData.providerData["profileImageURL"] as? String {
            UserService.us.REF_USER_CURRENT.childByAppendingPath("profileImageURL").setValue(imageUrl)
        }
    }
    
    func createUser(authData: FAuthData, completion: (result: String) -> Void) {
        let name: String!
        
        if nameField.text != "" {
            name = nameField.text
        } else {
            name = (authData.providerData["displayName"] != nil) ? authData.providerData["displayName"] as? String: authData.providerData["email"] as? String
        }
        
        let user: Dictionary<String, AnyObject> = [
            "id": authData.uid as String,
            "name": name,
            "provider": authData.provider as String,
            "email": authData.providerData["email"] as! String,
            "profileImageURL": authData.providerData["profileImageURL"] as! String,
            "createdAt": kFirebaseServerValueTimestamp as Dictionary<String, String>,
            "updatedAt": kFirebaseServerValueTimestamp as Dictionary<String, String>
        ]
        
        DataService.ds.createFirebaseUser(authData.uid, user: user)
        
        // Set User Defaults just incase
        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE_TITLE)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UNIVESITY)
        completion(result: "Finished creating user")
    }
    
    func checkUserData(authData: FAuthData) {
        // check for if user exists and if they have a university selected
        DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let currentUser = User(uid: snapshot.key, dictionary: userDict)
                
                // Update the users Profile Picture
                
                
                // TODO: Remove need for StateService
                StateService.ss.setUser(currentUser)
                
                // TODO: Set last course to user-activity/users/[userId]/courseId
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
                NSUserDefaults.standardUserDefaults().setValue("Select a Course", forKey: KEY_COURSE_TITLE)
                
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
    
    
    
    
    // BUTTON ACTIONS
    
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
                    }
                })
            }
        })
    }
    
    
    @IBAction func attempLogin(sender: UIButton!) {
        
        if isRegistering {
            if nameField.text == "" {
                self.showErrorAlert("Could not register", msg: "Please include your full name.")
                return
            }
        }
        
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
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                                    error, authData in
                                    print("Authed new user with email / password")
                                })
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username and password.")
                    }
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password.")
        }
    }
    
    @IBAction func didTapRegisterBtn(sender: AnyObject) {
        if isRegistering {
            showNameFields()
        } else {
            hideNameFields()
        }
        isRegistering = !isRegistering
    }
}

