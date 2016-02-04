//
//  MaterialButtonSquare.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/24/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import UIKit

class MaterialButtonSquare: UIButton {
    override func awakeFromNib() {
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(-1.0, -1.0)
    }
}