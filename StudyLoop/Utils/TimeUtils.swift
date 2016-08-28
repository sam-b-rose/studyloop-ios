//
//  TimeUtils.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/24/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation

class TimeUtils {
    
    static let tu = TimeUtils()
    
    func timeStringFromUnixTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime / 1000)
        let dateFormatter = NSDateFormatter()
        
        // Returns date formatted as 12 hour time.
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }

    func dayStringFromTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime / 1000)
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(date)
    }
}

// MARK: Operator overloading for date comparisons
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}