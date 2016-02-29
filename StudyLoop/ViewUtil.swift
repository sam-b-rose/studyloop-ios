//
//  ViewUtil.swift
//  StudyLoop
//
//  Created by Chris Martin on 2/27/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation
import UIKit

class PassThroughView: UIView {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.hidden && subview.alpha > 0 && subview.userInteractionEnabled && subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                return true
            }
        }
        return false
    }
}

enum SLTransitionDirection {
    case Forwards
    case Backwards
}