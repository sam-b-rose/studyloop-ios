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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_UNIVERSITIES.observeEventType(.Value, withBlock: { snapshot in
            self.universities = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let universitiesDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        print(key, universitiesDict)
                        
                        // Create University Object
                        let university = University(universityKey: key, dictionary: universitiesDict)
                        self.universities.append(university)
                        print(self.universities)
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
        StateService.ss.CURRENT_USER?.setUniversity(universities[indexPath.row].universityKey)
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
