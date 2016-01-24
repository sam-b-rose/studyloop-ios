//
//  StringUtils.swift
//  StudyLoop
//
//  Created by Sam Rose on 1/24/16.
//  Copyright © 2016 StudyLoop. All rights reserved.
//

import Foundation

class StringUtils {
    static let su = StringUtils()
    
    func trimLeadingZeroes(input: String) -> String {
        var result = ""
        for character in input.characters {
            if result.isEmpty && character == "0" { continue }
            result.append(character)
        }
        return result
    }
}