//
//  ChooseUniversityViewController.swift
//  StudyLoop
//
//  Created by Chris Martin on 2/27/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class ChooseUniversityViewController: UIViewController, UITextFieldDelegate {

    // MARK: Constants
    private let TEXT_FIELD_DEFAULT_POS: CGFloat = 153
    private let TEXT_FIELD_ADJUSTED_POS: CGFloat = 29
    
    // MARK: UI Elements
    @IBOutlet weak var universityTextField: UITextField!
    
    // MARK: Constraints
    @IBOutlet weak var textFieldYPosConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        universityTextField.delegate = self
        self.universityTextField.borderStyle = .RoundedRect
        
        // Register Listener for Text Field
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidBecomeActive:"), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidResignActive:"), name: UITextFieldTextDidEndEditingNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBecomeActive(notification: NSNotification) {
        UIView.animateWithDuration(DEFAULT_TRANSITION_TIME) { () -> Void in
            self.textFieldYPosConstraint.constant = self.TEXT_FIELD_ADJUSTED_POS
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidResignActive(notification: NSNotification) {
        UIView.animateWithDuration(DEFAULT_TRANSITION_TIME) { () -> Void in
            self.textFieldYPosConstraint.constant = self.TEXT_FIELD_DEFAULT_POS
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
