//
//  Constants.swift
//  StudyLoop
//
//  Created by Sam Rose on 11/29/15.
//  Copyright © 2015 StudyLoop. All rights reserved.
//

import Foundation
import UIKit

let SHADOW_COLOR: CGFloat = 157.0 / 255.0

// Firebase Timestamp
let kFirebaseServerValueTimestamp = [".sv":"timestamp"]

// Keys
let KEY_UID = "uid"
let KEY_COURSE = "course"
let KEY_COURSE_TITLE = "courseTitle"

// Segues
let SEGUE_LOGGED_IN = "loggedIn"
let SEGUE_LOGGED_OUT = "loggedOut"
let SEGUE_SETTINGS = "settings"
let SEGUE_SELECT_UNIVERSITY = "selectUniversity"
let SEGUE_ADD_COURSE = "addCourse"
let SEGUE_COURSE = "course"
let SEGUE_LOOP = "loop"
let SEGUE_ADD_LOOP = "addLoop"

// Status Codes
let STATUS_ACCOUNT_NONEXSIT = -8