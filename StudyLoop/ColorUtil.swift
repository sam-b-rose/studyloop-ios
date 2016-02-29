//
//  ColorUtil.swift
//  StudyLoop
//
//  Created by Chris Martin on 2/19/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func blendColor(color2: UIColor, amount: CGFloat) -> UIColor {
        var cc = [CGFloat].init(count: 4, repeatedValue: 0.0)
        var nc = [CGFloat].init(count: 4, repeatedValue: 0.0)
        var bc = [Float].init(count: 4, repeatedValue: 0.0)
        
        // Set initial values
        getRed(&cc[0], green: &cc[1], blue: &cc[2], alpha: &cc[3])
        color2.getRed(&nc[0], green: &nc[1], blue: &nc[2], alpha: &nc[3])
        
        for i in 0...3 {
            bc[i] = Float(cc[i] * (1-amount) + nc[i] * (amount))
        }
        
        return UIColor(colorLiteralRed: bc[0], green: bc[1], blue: bc[2], alpha: bc[3])
    }
}