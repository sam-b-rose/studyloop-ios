//
//  UserImage.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/25/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import UIKit

class UserImage: UIImageView {
    
    override func awakeFromNib() {
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
}