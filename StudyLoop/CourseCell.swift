//
//  CourseCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/31/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit

class CourseCell: UITableViewCell {

    @IBOutlet weak var courseLabel: UILabel!
    
    var course: Course!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(course: Course) {
        self.course = course
        self.courseLabel.text = "\(course.major) \(course.number) – \(course.instructor)"
    }

}
