//
//  TwitterRequest.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/2/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import TwitterKit
import SwiftyJSON

typealias TwitterResponse = ([TWTRTweet]) -> Void
typealias TwitterAPIResponse = (AnyObject, NSError?) -> Void

protocol APITwitterProtocol {
    func didRecieveAPIResults(tweets: [TWTRTweet])
}

struct TwitterRequest {
    var delegate: APITwitterProtocol?
    
    func getTweets() {
        self.unwrapData { (tweets) in
            self.delegate?.didRecieveAPIResults(tweets)
        }
    }
    
    func unwrapData(onComplete: TwitterResponse) {
        self.makeRequest { (json, error) in
            let jsonArray = json?.arrayObject
            let tweets: [TWTRTweet] = TWTRTweet.tweetsWithJSONArray(jsonArray) as! [TWTRTweet]
            onComplete(tweets)
        }
    }
    
    private func makeRequest(onComplete: JsonResponse) {
        let userID: String? = Twitter.sharedInstance().sessionStore.session()?.userID
        
        guard userID != nil else {
            print("no paso el userId")
            return
        }
        
        let client = TWTRAPIClient(userID: userID)
        let endPoint: String = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params: [String: String] = ["count": "10", "trim_user": "false"]
        var clientError: NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endPoint, parameters: params, error: &clientError)
        
        guard clientError == nil else {
            return
        }
        
        client.sendTwitterRequest(request) { (response, data, error) -> Void in
            guard error == nil else {
                return
            }
            
            guard let tweets = data else {
                return
            }
            
            let json: JSON = JSON(data: tweets)
            onComplete(json, nil)
        }
    }
}