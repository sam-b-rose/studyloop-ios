//
//  MenuItem.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/29/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation

class MenuItem {
    private var _title: String!
    private var _borderTop: Bool!
    
    var title: String {
        return _title
    }
    
    var borderTop: Bool {
        return _borderTop
    }
    
    init(title: String) {
        self._title = title
        self._borderTop = false
    }
    
    init(title: String, borderTop: Bool) {
        self._title = title
        self._borderTop = borderTop
    }
}