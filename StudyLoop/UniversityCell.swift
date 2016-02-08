//
//  UniversityCell.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/24/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit
import Firebase

class UniversityCell: UITableViewCell {
    
    @IBOutlet weak var universityName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(university: University) {
        self.universityName.text = university.name
    }
}
