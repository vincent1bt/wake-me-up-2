//
//  NewsRequest.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/1/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias NewsResonse = ([News]?, NSError?) -> Void

protocol APInewsProtocol {
    func didRecieveAPIResults(news: [News])
}

struct NewsRequest {
    var delegate: APInewsProtocol?
    let request: Request = Request()
    
    func getNews() {
        unwrapData { (data, error) in
            guard error == nil else {
                return
            }
            
            guard let news = data else {
                return
            }
            self.delegate?.didRecieveAPIResults(news)
        }
    }
    
    func unwrapData(onComplete: NewsResonse) {
        let endPoint: String = "https://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/1.json?api-key=\(Keys.News.key)"
        request.makeRequest(endPoint) { (data, error) in
            guard error == nil else {
                onComplete(nil, error)
                return
            }
            
            guard let json = data else {
                onComplete(nil, nil)
                return
            }
            
            guard let results = json["results"].array else {
                onComplete(nil, error)
                return
            }
            
            var newsArray: [News] = [News]()
            
            for new in results {
                var newItem = News()
                newItem.title = new["title"].stringValue
                newItem.date = (new["published_date"].stringValue).componentsSeparatedByString("T")[0]
                newItem.content =  new["abstract"].stringValue
                
                if let imagesArray = ((new["media"].arrayValue).first)?["media-metadata"].arrayValue {
                    if imagesArray.count >= 7 {
                        let imageUrl = imagesArray[6]["url"].string
                        if let url =  NSURL(string: imageUrl!) {
                            if let data = NSData(contentsOfURL: url) {
                                newItem.image = data
                            }
                        }
                    }
                }
                newsArray.append(newItem)
            }
            onComplete(newsArray, nil)
        }
    }
}