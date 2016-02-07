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
    @IBOutlet weak var loginBtn: MaterialButton!
    @IBOutlet weak var facebookBtn: MaterialButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    // States
    var isRegistering = false
    var isForgotPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide name field initially
        loginState()
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        // Clear Login info
        self.resetLoginScreen()
    }
    
    
    
    // MARK: - View State Helpers
    
    func loginState() {
        titleLbl.text = "Login"
        nameField.frame.size.height = 0
        nameField.hidden = true
        passwordField.hidden = false
        passwordField.frame.size.height = 35
        loginBtn.setTitle("Login", forState: .Normal)
        facebookBtn.hidden = false
        facebookBtn.setTitle("FACEBOOK LOGIN", forState: .Normal)
        forgotBtn.hidden = false
        forgotBtn.setTitle("Forgot password?", forState: .Normal)
        registerBtn.setTitle("Not registered? Sign up!", forState: .Normal)
        isRegistering = false
        isForgotPassword = false
    }
    
    func registerState() {
        titleLbl.text = "Register"
        nameField.frame.size.height = 35
        nameField.hidden = false
        passwordField.hidden = false
        passwordField.frame.size.height = 35
        loginBtn.setTitle("Register", forState: .Normal)
        facebookBtn.hidden = false
        facebookBtn.setTitle("FACEBOOK REGISTER", forState: .Normal)
        forgotBtn.hidden = true
        registerBtn.setTitle("Already have an account? Login!", forState: .Normal)
        isRegistering = true
        isForgotPassword = false
    }
    
    func forgotPasswordState() {
        titleLbl.text = "Enter your email to receive a temporary password."
        nameField.hidden = true
        nameField.frame.size.height = 0
        passwordField.hidden = true
        passwordField.frame.size.height = 0
        forgotBtn.setTitle("Cancel", forState: .Normal)
        loginBtn.setTitle("Send", forState: .Normal)
        facebookBtn.hidden = true
        isRegistering = false
        isForgotPassword = true
    }
    
    func resetLoginScreen() {
        nameField.text = ""
        emailField.text = ""
        passwordField.text = ""
        loginState()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func createUser(authData: FAuthData, completion: (result: String) -> Void) {
        let name: String!
        var gender = ""
        
        if nameField.text != "" {
            name = nameField.text
        } else {
            name = (authData.providerData["displayName"] != nil) ? authData.providerData["displayName"] as? String: authData.providerData["email"] as? String
        }
        
        if authData.providerData["gender"] != nil {
            gender = authData.providerData["gender"] as! String
        }
        
        let user: Dictionary<String, AnyObject> = [
            "id": authData.uid as String,
            "name": name,
            "provider": authData.provider as String,
            "email": authData.providerData["email"] as! String,
            "gender": gender,
            "profileImageURL": authData.providerData["profileImageURL"] as! String,
            "createdAt": kFirebaseServerValueTimestamp as Dictionary<String, String>,
            "updatedAt": kFirebaseServerValueTimestamp as Dictionary<String, String>
        ]
        
        UserService.us.createFirebaseUser(authData.uid, user: user)
        
        // Set User Defaults just incase
        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE)
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_COURSE_TITLE)
        completion(result: "Finished creating user")
    }
    
    
    
    // MARK: - Button Actions
    
    @IBAction func fbBtnPressed(sender: MaterialButton!) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler: { (facebookResutl: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                print("Facebook login failed. Error: \(facebookError)")
            } else {
                if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString {
                    DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: {
                        error, authData in
                        if error != nil {
                            print("Firebase login via Facebook failed. Error: \(error)")
                            NotificationService.noti.showAlert("Problem with Facebook Login", msg: "We couldn't log you in with Facebook. Try again or re-register with Facebook.", uiView: self)
                        } else {
                            print("Logged in with Facebook!")
                            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                            UserService.us.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: {
                                snapshot in
                                if snapshot != nil {
                                    print("user already exsits, moving on")
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                } else {
                                    self.createUser(authData, completion: { (result) -> Void in
                                        print(result)
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    })
                                }
                            })
                        }
                    })
                } else {
                    print("Login failed. Bad accessToken")
                }
            }
        })
    }
    
    
    @IBAction func didTapPrimaryBtn(sender: MaterialButton!) {
        
        if isForgotPassword {
            // reset password
            if let email = emailField.text where email != "" {
                DataService.ds.REF_BASE.resetPasswordForUser(email, withCompletionBlock: {
                    error in
                    if error == nil {
                        NotificationService.noti.showAlert("Password Reset", msg: "You have been sent a temporary password. Login with this password, then go to Settings to change your password.", uiView: self)
                        self.loginState()
                        self.passwordField.text = ""
                    }
                })
            } else {
                NotificationService.noti.showAlert("Email Required", msg: "You must provide the email associated with your StudyLoop account in order to reset your password.", uiView: self)
            }
        } else {
            // attemptlogin
            if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
                
                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                    error, authData in
                    if error != nil {
                        if error.code == STATUS_ACCOUNT_NONEXSIT {
                            
                            if self.isRegistering {
                                if self.nameField.text != "" {
                                    // Create User in Firebase Auth
                                    DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                                        if error != nil {
                                            NotificationService.noti.showAlert("Could not create account", msg: "Problem creating a new account.", uiView: self)
                                        } else {
                                            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                                                error, authData in
                                                print("Creating new user with email / password")
                                                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                                                // Create User in Firebase Database
                                                self.createUser(authData, completion: { (result) -> Void in
                                                    self.performSegueWithIdentifier("unwindToInit", sender: self)
                                                })
                                            })
                                        }
                                    })
                                } else {
                                    NotificationService.noti.showAlert("Could not register new user", msg: "Please include your full name.", uiView: self)
                                }
                            } else {
                                NotificationService.noti.showAlert("User does not exist.", msg: "Please register before logging in.", uiView: self)
                            }
                            
                        } else {
                            NotificationService.noti.showAlert("Could not login", msg: "Please check your username and password.", uiView: self)
                        }
                    } else {
                        print("Logged in with Email!!")
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        UserService.us.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: {
                            snapshot in
                            if snapshot == nil {
                                self.performSegueWithIdentifier("unwindToInit", sender: self)
                            } else {
                                self.createUser(authData, completion: { (result) -> Void in
                                    self.performSegueWithIdentifier("unwindToInit", sender: self)
                                })
                            }
                        })
                    }
                })
                
            } else {
                NotificationService.noti.showAlert("Email and Password Required", msg: "You must enter an email and a password.", uiView: self)
            }
        }
    }
    
    @IBAction func didTapFogotBtn(sender: AnyObject) {
        isForgotPassword = !isForgotPassword
        
        if isForgotPassword == true {
            forgotPasswordState()
        } else {
            loginState()
        }
    }
    
    @IBAction func didTapRegisterBtn(sender: AnyObject) {
        isRegistering = !isRegistering
        
        if isRegistering == true {
            registerState()
        } else {
            loginState()
        }
    }
}

