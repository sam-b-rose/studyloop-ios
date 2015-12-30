//
//  StateService.swift
//  StudyLoop
//
//  Created by Sam Rose on 12/30/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation

class StateService {
    static let ss = StateService()
    
    private var _CURRENT_STATE: String!
    private var _STATE_SETTINGS = "settings"
    private var _STATE_LOOP = "loop"
    
    var CURRENT_STATE: String {
        return _CURRENT_STATE
    }
    
    var STATE_SETTINGS: String {
        return _STATE_SETTINGS
    }
    
    var STATE_LOOP: String {
        return _STATE_LOOP
    }
    
    init() {
        _CURRENT_STATE = STATE_LOOP
    }
    
    func setState(state: String) {
        _CURRENT_STATE = state
    }
}