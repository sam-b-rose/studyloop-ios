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
import FuzzySearch

class AddCourseVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: MaterialButton!
    @IBOutlet weak var majorInput: MaterialTextField!
    @IBOutlet weak var numberInput: MaterialTextField!
    @IBOutlet weak var instructorInput: MaterialTextField!
    
    var courses = [Course]()
    var courseResults = [Course]()
    var query = ""
    let threshold = 0.1
    let majorSortDescriptor = NSSortDescriptor(key: "major", ascending: true, selector: "localizedStandardCompare:")
    let numberSortDescriptor = NSSortDescriptor(key: "number", ascending: true, selector: "localizedStandardCompare:")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get Course Data
        if(StateService.ss.COURSES?.count == 0) {
            StateService.ss.getCourses()
        }
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
        // TODO: Add Course to User
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    @IBAction func searchCourses(sender: AnyObject) {
        print("search for :", majorInput.text!, numberInput.text!, instructorInput.text)
        
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
