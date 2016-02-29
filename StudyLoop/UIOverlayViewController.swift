//
//  UIOverlayViewController.swift
//  StudyLoop
//
//  Created by Chris Martin on 2/26/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class UIOverlayViewController: UIViewController {
    
    // MARK: - Constants
    private let BACK_WIDTH: CGFloat = 121
    private let ILABEL_YPOSITION: CGFloat = 40
    
    // MARK: UI Elements
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var effectLabel: UILabel!
    
    // MARK: Delegation
    var delegate: UserOnboardingDelegate!
    
    // MARK: Constraints
    @IBOutlet weak var backButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logInButtonYPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var getStartedToLogInYPostitionConstraint: NSLayoutConstraint!
    @IBOutlet weak var informationLabelYPositionConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    var keyboardIsHidden: Bool! = true
    var textFieldIsEditing: Bool! = false
    
    // MARK: - View Delegate Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Clear out the background
        self.view.backgroundColor = UIColor.clearColor()
        
        // Set up text box and page control
        self.informationLabel.text = ""
        self.pageControl.alpha = 0
        self.effectLabel.alpha = 0
        
        // Set Targets for Buttons
        self.getStartedButton.addTarget(self, action: Selector("getStartedButtonPressed:"), forControlEvents: .TouchUpInside)
        self.logInButton.addTarget(self, action: Selector("logInButtonPressed:"), forControlEvents: .TouchUpInside)
        self.backButton.addTarget(self, action: Selector("backButtonPressed:"), forControlEvents: .TouchUpInside)
        
        // Register Listener for Keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidChange:"), name: UIKeyboardDidChangeFrameNotification, object: nil)
        
        // Register Listener for Text Field
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidBecomeActive:"), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidResignActive:"), name: UITextFieldTextDidEndEditingNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button Responder Functions
    
    func getStartedButtonPressed(sender: UIButton) {
        if self.delegate.advanceByOne() == true {
            performTransitionOnIndexChange(delegate.pageIndex, withDirection: .Forwards)
        }
    }
    
    func logInButtonPressed(sender: UIButton) {
//        self.delegate.receedByOne()
    }
    
    func backButtonPressed(sender: UIButton) {
        if self.delegate.receedByOne() == true {
            performTransitionOnIndexChange(delegate.pageIndex, withDirection: .Backwards)
        }
    }
    
    // MARK: Keyboard Responder Functions
    
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] else { return }
        let keyboardSize = keyboardInfo.CGRectValue.size
        
        self.keyboardIsHidden = false
        
        UIView.animateWithDuration(DEFAULT_TRANSITION_TIME) { () -> Void in
            self.getStartedToLogInYPostitionConstraint.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.keyboardIsHidden = true
        
        UIView.animateWithDuration(DEFAULT_TRANSITION_TIME) { () -> Void in
            self.getStartedToLogInYPostitionConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardDidChange(notification: NSNotification) {
        guard let keyboardHidden = keyboardIsHidden where keyboardHidden == false else { return } // So elegant
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardInfo = userInfo[UIKeyboardFrameEndUserInfoKey] else { return }
        let keyboardSize = keyboardInfo.CGRectValue.size
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.getStartedToLogInYPostitionConstraint.constant = keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Text Field Responder Functions
    
    func textFieldDidBecomeActive(notification: NSNotification) {
        self.textFieldIsEditing = true
        
        // Hide Information Label
        self.fadeOutView(informationLabel, withDuration: DEFAULT_TRANSITION_TIME)
        
        // Raise the page control to top
        UIView.animateWithDuration(DEFAULT_TRANSITION_TIME) { () -> Void in
            self.informationLabelYPositionConstraint.constant = -self.informationLabel.bounds.height
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidResignActive(notification: NSNotification) {
        self.textFieldIsEditing = false
        
        // Reveal Information Label
        self.fadeInView(informationLabel, withDuration: DEFAULT_TRANSITION_TIME)
        
        // Raise the page control to top
        UIView.animateWithDuration(DEFAULT_TRANSITION_TIME) { () -> Void in
            self.informationLabelYPositionConstraint.constant = self.ILABEL_YPOSITION
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Transition Handler Functions
    
    func performTransitionOnIndexChange(index: Int, withDirection direction: SLTransitionDirection) {
        
        // Set page control index
        self.pageControl.currentPage = index-1 <= 0 ? 0 : index-1
        
        // Perform page-unique animations
        switch(index) {
        case 0:
            self.animateLabel(informationLabel, withHelperLabel: effectLabel, toText: "", inDirection: direction, withTransitionDelta: 30, withDuration: DEFAULT_TRANSITION_TIME)
            UIView.animateWithDuration(DEFAULT_TRANSITION_TIME, animations: { () -> Void in
                self.pageControl.alpha = 0
                self.getStartedButton.setTitle("Get Started", forState: .Normal)
                self.backButtonWidthConstraint.constant = 0
                self.logInButtonYPositionConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        case 1:
            let text = "Converse with your classmates about upcoming assignments and exams, with topics in their own sections, called “loops”."
            if self.textFieldIsEditing == false {
                self.animateLabel(informationLabel, withHelperLabel: effectLabel, toText: text, inDirection: direction, withTransitionDelta: 30, withDuration: DEFAULT_TRANSITION_TIME)
            }
            
            UIView.animateWithDuration(DEFAULT_TRANSITION_TIME, animations: { () -> Void in
                self.pageControl.alpha = 1
                self.getStartedButton.setTitle("Next", forState: .Normal)
                self.backButtonWidthConstraint.constant = self.BACK_WIDTH
                self.logInButtonYPositionConstraint.constant = -self.logInButton.bounds.height
                self.view.layoutIfNeeded()
            })
        case 2:
            let text = "StudyLoop automatically matches you with other people in your classes. Enter your University below to get started."
//            self.animateLabel(informationLabel, toText: text, withDuration: DEFAULT_TRANSITION_TIME)
            if self.textFieldIsEditing == false {
                self.animateLabel(informationLabel, withHelperLabel: effectLabel, toText: text, inDirection: direction, withTransitionDelta: 30, withDuration: DEFAULT_TRANSITION_TIME)
            }
            
            UIView.animateWithDuration(DEFAULT_TRANSITION_TIME, animations: { () -> Void in
                self.pageControl.alpha = 1
                self.getStartedButton.setTitle("Next", forState: .Normal)
                self.backButtonWidthConstraint.constant = self.BACK_WIDTH
                self.logInButtonYPositionConstraint.constant = -self.logInButton.bounds.height
                self.view.layoutIfNeeded()
            })
        default: break
        }
    }
    
    // MARK: - Animation Helper Functions
    
    func animateLabel(mainLabel: UILabel, withHelperLabel helperLabel: UILabel, toText text: String, inDirection direction: SLTransitionDirection, var withTransitionDelta delta: CGFloat, withDuration duration: CFTimeInterval) {
        if direction == .Backwards { delta = -delta }
        
        helperLabel.alpha = 0
        helperLabel.text = text
        helperLabel.frame.origin.y -= delta // Offset
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            helperLabel.alpha = 1
            helperLabel.frame.origin.y += delta // Origin
            
            mainLabel.alpha = 0
            mainLabel.frame.origin.y += delta // Offset
            }) { (success) -> Void in
                // Reset Main Label
                mainLabel.alpha = 1
                mainLabel.frame.origin.y -= delta // Origin
                mainLabel.text = text
                
                // Reset Helper Label
                helperLabel.alpha = 0
        }
    }
    
    func animateLabel(label: UILabel, toText text: String, withDuration duration: CFTimeInterval) {
        UIView.animateWithDuration(duration/2, animations: { () -> Void in
            label.alpha = 0
            }) { (completed) -> Void in
                label.text = text
                UIView.animateWithDuration(duration/2, animations: { () -> Void in
                    label.alpha = 1
                })
        }
    }
    
    func fadeOutView(view: UIView, withDuration duration: CFTimeInterval) {
        UIView.animateWithDuration(duration) { () -> Void in
            view.alpha = 0
        }
    }
    
    func fadeInView(view: UIView, withDuration duration: CFTimeInterval) {
        UIView.animateWithDuration(duration) { () -> Void in
            view.alpha = 1
        }
    }
}
