//
//  DataService.swift
//  StudyLoop
//
//  Created by Sam Rose on 11/29/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "https://studyloop-stage.firebaseio.com")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
}