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
    private var _courseId: String!
    private var _hasNotification: Bool!
    
    var title: String {
        return _title
    }
    
    var courseId: String {
        return _courseId
    }
    
    var hasNotification: Bool {
        return _hasNotification
    }
    
    init(title: String) {
        self._title = title
        self._hasNotification = false
        self._courseId = ""
    }
    
    init(title: String, courseId: String, notify: Bool) {
        self._title = title
        self._courseId = courseId
        self._hasNotification = false
    }
}