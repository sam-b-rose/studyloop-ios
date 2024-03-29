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

// Firebase
let URL_BASE = "https://studyloop-stage.firebaseio.com"  // Dev
// let URL_BASE = "https://studyloop-prod.firebaseio.com" // Production
let kFirebaseServerValueTimestamp = [".sv":"timestamp"]

// Verification URLs
let URL_VERIFY_EMAIL = "https://studyloop-stage.firebaseapp.com/#/auth/verify/email/request/"
//let URL_VERIFY_EMAIL = "https://app.getstudyloop.com/#/auth/verify/email/request/"

// Images
let IMAGE_BASE = "https://s3.amazonaws.com/sl-attachments/"

// Keys
let KEY_DEVICE_ID = "deviceId"
let KEY_UID = "uid"
let KEY_COURSE = "course"
let KEY_COURSE_TITLE = "courseTitle"
let KEY_LOOP = "loop"

// Events
let NOTIFICATION = "notification"
let REFRESH_LOOPS = "REFRESH_LOOPS"

// Notification Types
let LOOP_MESSAGE_RECEIVED = "LOOP_MESSAGE_RECEIVED"
let LOOP_CREATED = "LOOP_CREATED"

// View Controllers
let VIEW_CONTROLLER_ADD_COURSE = "AddCourseViewController"
let VIEW_CONTROLLER_ADD_LOOP = "AddLoopViewController"
let VIEW_CONTROLLER_APP_SETTINGS = "AppSettingsViewController"
let VIEW_CONTROLLER_CHANGE_PASSWORD = "ChangePasswordViewController"
let VIEW_CONTROLLER_VERIFY_EMAIL = "VerifyEmailViewController"
let VIEW_CONTROLLER_COURSE = "CourseVC"
let VIEW_CONTROLLER_COURSE_SETTINGS = "CourseSettingsViewController"
let VIEW_CONTROLLER_DRAWER = "DrawerViewController"
let VIEW_CONTROLLER_DRAWER_CONTROLLER = "DrawerControllerViewController"
let VIEW_CONTROLLER_INITIAL = "InitialViewController"
let VIEW_CONTROLLER_LOGIN = "LoginViewController"
let VIEW_CONTROLLER_LOOP_SETTINGS = "LoopSettingsViewController"
let VIEW_CONTROLLER_MEMBERS = "MembersViewController"
let VIEW_CONTROLLER_MESSAGES = "MessagesViewController"
let VIEW_CONTROLLER_UNIVERSITY = "UniversityViewController"

// Navigation Controllers
let NAVIGATION_CONTROLLER_DRAWER = "DrawerNavigation"
let NAVIGATION_CONTROLLER_MAIN = "MainNavigation"

// Segues
let SEGUE_LOGGED_IN = "loggedIn"
let SEGUE_LOGGED_OUT = "loggedOut"
let SEGUE_FORGOT_PASSWORD = "forgotPassword"
let SEGUE_SETTINGS = "appSettings"
let SEGUE_UNWIND_TO_INIT = "unwindToInit"
let SEGUE_VERIFY_EMAIL = "verifyEmail"
let SEGUE_CHANGE_PWD = "changePassword"
let SEGUE_COURSE_SETTINGS = "courseSettings"
let SEGUE_LOOP_SETTINGS = "loopSettings"
let SEGUE_SELECT_UNIVERSITY = "selectUniversity"
let SEGUE_ADD_COURSE = "addCourse"
let SEGUE_COURSE = "course"
let SEGUE_LOOP = "loop"
let SEGUE_MESSAGES = "messagesVC"
let SEGUE_PREVIEW_IMAGE = "previewImage"
let SEGUE_VIEW_IMAGE = "viewImage"
let SEGUE_ADD_LOOP = "addLoop"
let SEGUE_MEMBERS = "members"

// Status Codes
let STATUS_ACCOUNT_NONEXSIT = -8

// Colors
let SL_BLACK = UIColor(red:0.07, green:0.08, blue:0.09, alpha:1)
let SL_GRAY = UIColor(red:0.39, green:0.42, blue:0.5, alpha:1)
let SL_LIGHT = UIColor(red:0.87, green:0.94, blue:0.94, alpha:1)
let SL_WHITE = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1)
let SL_CORAL = UIColor(red:0.2, green:0.42, blue:0.4, alpha:1)
let SL_GREEN = UIColor(red:0, green:0.87, blue:0.74, alpha:1)
let SL_RED = UIColor(red:1, green:0.44, blue:0.42, alpha:1)