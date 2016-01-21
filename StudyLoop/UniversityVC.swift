//
//  SelectUniversityVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/23/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Firebase

class UniversityVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var universities = [University]()
    var previousVC: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.title = "Select University"
        
        // Hide Back Nav Button text
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
        
        DataService.ds.REF_UNIVERSITIES.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.universities = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let universitiesDict = snap.value as? Dictionary<String, AnyObject> {
                        // Create University Object
                        let university = University(universityKey: snap.key, dictionary: universitiesDict)
                        self.universities.append(university)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let university = universities[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("UniversityCell") as? UniversityCell {
            cell.configureCell(university)
            return cell
        } else {
            return UniversityCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key = universities[indexPath.row].universityKey
        UserService.us.REF_USER_CURRENT.childByAppendingPath("universityId").setValue(key, withCompletionBlock: {
            error, ref in
            if error == nil {
                print("Set the univeristy to \(key)")
                
                if self.previousVC == "LoginVC" {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else if self.previousVC == "AppSettingsVC" {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                
            } else {
                print("Error setting university")
            }
        })
        
        let userId = NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID) as? String
        DataService.ds.REF_UNIVERSITIES.childByAppendingPath(key).childByAppendingPath("userIds").childByAppendingPath(userId).setValue(true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
