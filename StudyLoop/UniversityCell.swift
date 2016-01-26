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
    
    let border = CALayer()
    var university: University!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(university: University) {
        self.university = university
        self.universityName.text = university.name
        
        border.backgroundColor = SL_GRAY.colorWithAlphaComponent(0.3).CGColor
        border.frame = CGRect(x: 15, y: 0, width: layer.frame.width - 15, height: 0.5)
        layer.addSublayer(border)
    }
}
