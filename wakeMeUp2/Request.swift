//
//  Request.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/3/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias JsonResponse = (JSON?, NSError?) -> Void

struct Request {
    let utils: Utils = Utils()
    func makeRequest(endPoint: String, onComplete: JsonResponse) {
        guard let url = NSURL(string: endPoint) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                onComplete(nil, error)
                return
            }
            
            guard let unwrapperData = data else {
                let info: [String: String] = [
                    "description": "The data is nil",
                    "code": "404",
                    "domain": "nilResponse",
                    "commentDescription": "Check the request",
                    "commentError": "Bad request"
                ]
                let error = self.utils.createNSError(info)
                onComplete(nil, error)
                return
            }
            
            let json = JSON(data: unwrapperData)
            onComplete(json, nil)
        }
        task.resume()
    }
}