//
//  ChooseUniversityViewController.swift
//  StudyLoop
//
//  Created by Chris Martin on 2/27/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class ChooseUniversityViewController: OnboardingGenericViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: Constants
    private let TEXT_FIELD_DEFAULT_POS: CGFloat = 153
    private let TEXT_FIELD_ADJUSTED_POS: CGFloat = 29
    private let BUTTON_SIZE: CGFloat = 66
    private let PADDING_SIZE: CGFloat = 8
    
    // MARK: UI Elements
    @IBOutlet weak var universityTextField: UITextField!
    @IBOutlet weak var selectionTableView: UITableView!
    var emptyLabel: UILabel!
    
    // MARK: Constraints
    @IBOutlet weak var textFieldYPosConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectionViewYBottomConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    var universityArray: [University]!
    var searchResults = [University]()
    var selectedIndex: Int!
    var keyboardIsHidden: Bool! = true
    
    // MARK: - View Delegate Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up index array
        self.selectedIndex = -1

        // Set up text field
        universityTextField.delegate = self
        self.universityTextField.borderStyle = .RoundedRect
        
        // Set up tableView
        selectionTableView.dataSource = self
        selectionTableView.delegate = self
        selectionTableView.layer.cornerRadius = 5
        selectionTableView.clipsToBounds = true
        
        // Set up university array
        let utk = University(name: "University of Tennessee, Knoxville", shortName: "UTK")
        self.universityArray = [utk]
        
        // Register Listener for Text Field
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidBecomeActive:"), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textFieldDidResignActive:"), name: UITextFieldTextDidEndEditingNotification, object: nil)
        universityTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        // Register Listener for Keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidChange:"), name: UIKeyboardDidChangeFrameNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Text Field Handlers
    
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
    
    func textFieldDidChange(textField: UITextField) {
        guard let searchText = textField.text?.lowercaseString else { return }
        self.searchResults = universityArray.filter({ (university) -> Bool in
            return university.name.lowercaseString.rangeOfString(searchText) != nil ? true : false
        })
        print("String: \(searchText), Results: \(searchResults)")
        self.selectedIndex = -1
        self.selectionTableView.reloadData()
    }
    
    // MARK: Keyboard Handlers
    
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] else { return }
        let keyboardSize = keyboardInfo.CGRectValue.size
        
        self.keyboardIsHidden = false
        
        UIView.animateWithDuration(DEFAULT_TRANSITION_TIME) { () -> Void in
            self.selectionViewYBottomConstraint.constant = keyboardSize.height + self.BUTTON_SIZE + self.PADDING_SIZE
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.keyboardIsHidden = true
        
        UIView.animateWithDuration(DEFAULT_TRANSITION_TIME) { () -> Void in
            self.selectionViewYBottomConstraint.constant = self.BUTTON_SIZE + self.PADDING_SIZE
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardDidChange(notification: NSNotification) {
        guard let keyboardHidden = keyboardIsHidden where keyboardHidden == false else { return } // So elegant
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardInfo = userInfo[UIKeyboardFrameEndUserInfoKey] else { return }
        let keyboardSize = keyboardInfo.CGRectValue.size
        
        UIView.animateWithDuration(0.1) { () -> Void in
            self.selectionViewYBottomConstraint.constant = keyboardSize.height + self.BUTTON_SIZE + self.PADDING_SIZE
            self.view.layoutIfNeeded()
        }
    }

    // MARK: TableView Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var displayedText: String
        
        if let text = self.universityTextField.text where text.isEmpty == true {
            displayedText = "Search for a University to get started!"
        } else {
            displayedText = "No Universities found."
        }
        
        if self.searchResults.count == 0 {
            let emptyLabel = UILabel(frame: CGRectMake(20, 0, tableView.bounds.size.width-40, tableView.bounds.size.height))
            emptyLabel.text = displayedText
            emptyLabel.textAlignment = .Center
            emptyLabel.textColor = UIColor.grayColor()
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .None
            return 0
        } else {
            tableView.backgroundView = UIView()
            tableView.separatorStyle = .SingleLine
            return self.searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("universityCell")!
        cell.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.text = searchResults[indexPath.row].name
        if self.selectedIndex == indexPath.row {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndex = indexPath.row
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        
        let university = self.universityArray[selectedIndex]
        super.setUniversity(university)
    }
    
    // MARK: - Misc Helper Functions
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
