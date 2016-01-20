//
//  FogotPasswordVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/19/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var emailField: MaterialTextField!
    
    override func viewDidLoad() {
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidDisappear(animated: Bool) {
        emailField.text = ""
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func didTapCancelBtn(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapSendBtn(sender: AnyObject) {
        if let txt = emailField.text where txt != "" {
            // reset pass
            dismissViewControllerAnimated(true, completion: nil)
        }
    }


}
