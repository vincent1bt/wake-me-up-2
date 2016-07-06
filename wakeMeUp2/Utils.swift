//
//  Utils.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/4/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation

struct Utils {
    func createNSError(keys: [String: String]) -> NSError {
        let userInfo: [NSObject: AnyObject] = [
            NSLocalizedDescriptionKey: NSLocalizedString(keys["description"]!, comment: keys["commentDescription"]!),
            NSLocalizedFailureReasonErrorKey: NSLocalizedString(keys["description"]!, comment: keys["commentError"]!)
        ]
        let error = NSError(domain: keys["domain"]!, code: Int(keys["code"]!)!, userInfo: userInfo)
        return error
    }
    
    func dateToString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        return formatter.stringFromDate(date)
    }
}