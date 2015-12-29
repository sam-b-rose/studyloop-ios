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
    
    var title: String {
        return _title
    }
    
    init(title: String) {
        self._title = title
    }
}