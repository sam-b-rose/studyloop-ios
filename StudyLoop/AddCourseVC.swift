//
//  AddCourseVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/30/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import KYDrawerController
import FuzzySearch

class AddCourseVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: MaterialButton!
    @IBOutlet weak var majorInput: MaterialTextField!
    @IBOutlet weak var numberInput: MaterialTextField!
    @IBOutlet weak var instructorInput: MaterialTextField!
    
    var courses = [Course]()
    var courseResults = [Course]()
    var query = ""
    let threshold = 0.1
    let progressHUD = ProgressHUD(text: "Loading")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        majorInput.delegate = self
        numberInput.delegate = self
        instructorInput.delegate = self
        
        self.view.addSubview(progressHUD)
        
        // Get Course Data
        if(StateService.ss.COURSES?.count == 0) {
            progressHUD.show()
            StateService.ss.getCourses({
                result in
                print(result)
                self.progressHUD.hide()
            })
        }
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        progressHUD.hide()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let course = courseResults[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CourseCell") as? CourseCell {
            cell.configureCell(course)
            return cell
        } else {
            return CourseCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let courseId = courseResults[indexPath.row].uid
        if let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String {
            DataService.ds.REF_USER_CURRENT.childByAppendingPath("courseIds").childByAppendingPath(courseId).setValue(true, withCompletionBlock: {
                error, ref in
                DataService.ds.REF_COURSES.childByAppendingPath(courseId).childByAppendingPath("userIds").childByAppendingPath(userId).setValue(true)
                NSUserDefaults.standardUserDefaults().setObject(courseId, forKey: KEY_COURSE)
                NSUserDefaults.standardUserDefaults().setObject(self.courseResults[indexPath.row].title, forKey: KEY_COURSE_TITLE)
            })
        } else {
            print("Failed to get User Defaults for courseId and userId")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func hideTextFields() {
        majorInput.frame.size.height = 0
        majorInput.hidden = true
        
        numberInput.frame.size.height = 0
        numberInput.hidden = true
        
        instructorInput.frame.size.height = 0
        instructorInput.hidden = true
        
        searchBtn.setTitle("Search Again", forState: .Normal)
    }
    
    func showTextFields() {
        let textFieldHeight: CGFloat = 35
        
        majorInput.frame.size.height = textFieldHeight
        majorInput.hidden = false
        
        numberInput.frame.size.height = textFieldHeight
        numberInput.hidden = false
        
        instructorInput.frame.size.height = textFieldHeight
        instructorInput.hidden = false
        
        searchBtn.setTitle("Search", forState: .Normal)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchCourses()
        return true
    }
    
    @IBAction func didTapSearchButton(sender: AnyObject) {
        
        if searchBtn.titleLabel?.text == "Search" {
            // Search
            searchCourses()
        } else {
            // Reset to search again
            showTextFields()
            courseResults.removeAll()
            tableView.reloadData()
        }
    }
    
    func searchCourses() {
        print("search for :", majorInput.text!, numberInput.text!, instructorInput.text)
        dismissKeyboard()
        hideTextFields()
        
        if majorInput.text != "" || numberInput.text != "" || instructorInput.text != "" {
            query = [majorInput.text!, numberInput.text!, instructorInput.text!].joinWithSeparator(" ").lowercaseString
            let filtered = StateService.ss.COURSES!.filter({ course in
                var comp = [String]()
                
                if majorInput.text != "" {
                    comp.append(course.major)
                }
                
                if numberInput.text != "" {
                    comp.append(String(course.number))
                }
                
                if instructorInput.text != "" {
                    comp.append(course.instructor)
                }
                
                let compStr = comp.joinWithSeparator(" ").lowercaseString
                let score = FuzzySearch.score(originalString: query, stringToMatch: compStr)
                
                if score >= threshold {
                    print(query, compStr, score)
                }
                
                return score >= threshold
            })
            
            courseResults = filtered.sort {
                a, b -> Bool in
                return "\(a.major) \(a.number)" > "\(b.major) \(b.number)"
            }
            
            tableView.reloadData()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
