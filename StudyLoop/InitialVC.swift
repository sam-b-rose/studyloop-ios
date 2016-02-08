//
//  InitialVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 2/6/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit
import Firebase

class InitialVC: UIViewController {
    
    var authHandle: UInt!
    var authRef: Firebase!
    var deviceRef: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authRef = DataService.ds.REF_BASE
        deviceRef = DataService.ds.REF_QUEUES.childByAppendingPath("user-devices").childByAppendingPath("tasks")
    }
    
    override func viewDidAppear(animated: Bool) {
        // Check if user is already authenticated
        authHandle = authRef.observeAuthEventWithBlock({
            authData in
            if authData != nil {
                NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                self.saveDeviceId(authData.uid)
                UserService.us.watchCurrentUser({ (result) -> Void in
                    if result == true {
                        UserService.us.isUserVerified({ (result) -> Void in
                            if result == true {
                                NotificationService.noti.getNotifications()
                                UserService.us.updateProfilePicture(authData.providerData["profileImageURL"])
                                UserService.us.updateIsTempPass(authData.providerData["isTemporaryPassword"])
                                print("User is Authentic", authData.uid)
                                self.setRootViewController(VIEW_CONTROLLER_DRAWER_CONTROLLER)
                            } else {
                                print("Needs to verify email")
                                print(UserService.us.currentUser)
                                self.setRootViewController(VIEW_CONTROLLER_VERIFY_EMAIL)
                            }
                        })
                    } else {
                        print("User not Authentic")
                        self.setRootViewController(VIEW_CONTROLLER_LOGIN)
                    }
                })
            } else {
                print("User not Authentic")
                self.setRootViewController(VIEW_CONTROLLER_LOGIN)
            }
        })
    }
    
    func setRootViewController(viewControllerName: String) -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let targetViewController = storyboard.instantiateViewControllerWithIdentifier(viewControllerName)
        let application = UIApplication.sharedApplication()
        let window = application.delegate?.window
        window??.rootViewController = targetViewController
    }

    func saveDeviceId(userId: String) {
        if let deviceId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_DEVICE_ID) as? String {
            deviceRef.childByAutoId().setValue([
                "createdAt": kFirebaseServerValueTimestamp,
                "updatedAt": kFirebaseServerValueTimestamp,
                "userId": userId,
                "vendor": "ios",
                "vendorId": deviceId
                ])
        }
    }
    
    @IBAction func unwindToInit(segue: UIStoryboardSegue) { }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if authHandle != nil {
            print("Removed Auth Observer")
            authRef.removeAuthEventObserverWithHandle(authHandle)
        }
    }
}
