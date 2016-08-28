//
//  Loggable.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/21/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

enum LogLevel: Int {
    case Debug = 1, Info, Error
}

let log_level = LogLevel.Debug

protocol Loggable {
    func log()
    func log_error()
    func log_debug()
}

extension String: Loggable {
    func log() {
        if log_level.rawValue <= LogLevel.Info.rawValue {
            print("[info]\t\(self)")
        }
    }
    
    func log_error() {
        if log_level.rawValue <= LogLevel.Error.rawValue {
            print("[error]\t\(self)")
        }
    }
    
    func log_debug() {
        if log_level.rawValue <= LogLevel.Debug.rawValue {
            print("[debug]\t\(self)")
        }
    }
}