//
//  AddLoopVC.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/5/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class AddLoopVC: UIViewController {

    @IBOutlet weak var loopSubjectField: MaterialTextField!
    
    let attributes = [NSFontAttributeName: UIFont.ioniconOfSize(20)] as Dictionary!
    
    override func viewDidLoad() {
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        navigationItem.title = "New Loop"
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func didTapAddLoopBtn(sender: AnyObject) {
        if let txt = loopSubjectField.text where txt != "" {
            let newLoop: Dictionary<String, AnyObject> = [
                "courseId": NSUserDefaults.standardUserDefaults().objectForKey(KEY_COURSE)!,
                "createdAt": kFirebaseServerValueTimestamp,
                "createdById": NSUserDefaults.standardUserDefaults().objectForKey(KEY_UID)!,
                "subject": loopSubjectField.text!,
                "universityId": NSUserDefaults.standardUserDefaults().objectForKey(KEY_UNIVESITY)!
            ]
            
            DataService.ds.REF_QUEUES.childByAppendingPath("loops").childByAppendingPath("tasks").childByAutoId().setValue(newLoop, withCompletionBlock: {
                error, ref in
                if error == nil {
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    print("Error creating new loop.", error)
                }
            })
            
        }
    }
}
