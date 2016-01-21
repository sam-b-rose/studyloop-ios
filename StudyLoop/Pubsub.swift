//
//  Pubsub.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/21/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation

typealias Callback = () -> ()

struct Event {
    static var events = Dictionary<String, Array<Callback>>()
    
    static func register(event: String, callback: Callback) {
        if (self.events[event] == nil) {
            "Initializing list for event '\(event)'".log_debug()
            self.events[event] = Array<Callback>()
        }
        
        if var callbacks = self.events[event] {
            callbacks.append(callback)
            self.events[event] = callbacks
            "Registered callback for event '\(event)'".log_debug()
        } else {
            "Failed to register callback for event \(event)".log_error()
        }
    }
    
    static func emit(event: String) {
        "Emitting event '\(event)'".log_debug()
        if let events = self.events[event] {
            "Found list for event '\(event)', of length \(events.count)".log_debug()
            for callback in events {
                callback()
            }
        } else {
            "Could not find callbacks for event '\(event)'".log_error()
        }
    }
}