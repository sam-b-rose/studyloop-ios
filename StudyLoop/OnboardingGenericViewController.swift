//
//  OnboardingGenericViewController.swift
//  StudyLoop
//
//  Created by Chris Martin on 2/29/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import UIKit

class OnboardingGenericViewController: UIViewController {
    
    var delegate: UserOnboardingDelegate!
    
    func setUniversity(university: University) {
        guard delegate != nil else { return }
        delegate.university = university
    }
    
    func addCourse(course: Course) {
        guard delegate != nil else { return }
        delegate.courses.append(course)
    }
    
    func removeCourse(course: Course) {
        guard delegate != nil else { return }
        guard let courses = delegate.courses else { return }
        let courseNames = courses.lazy.map() { $0.uid }
        if let index = courseNames.indexOf(course.uid) {
            delegate.courses.removeAtIndex(index)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
    }
}
