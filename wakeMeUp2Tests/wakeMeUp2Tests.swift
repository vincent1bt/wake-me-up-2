//
//  wakeMeUp2Tests.swift
//  wakeMeUp2Tests
//
//  Created by vicente rodriguez on 6/26/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import XCTest
import MapKit

@testable import wakeMeUp2

class wakeMeUp2Tests: XCTestCase {
    
    let newsApi: NewsRequest = NewsRequest()
    let twitterApi: TwitterRequest = TwitterRequest()
    let weatherApi: WeatherRequest = WeatherRequest()
    let location = CLLocation(latitude: CLLocationDegrees(19.4993813631165) , longitude: CLLocationDegrees(-96.8489498739627))
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlacesApi() {
        FoursquareRequest.sharedInstance.unwrapData(self.location) { (places, annotations) in
            XCTAssertNotNil(places, "Places are nil")
            XCTAssertNotNil(annotations, "Annotations are nil")
            let place = places[0]
            let annotation = annotations[0]
            XCTAssertNotEqual(place.id, "No Id")
            XCTAssertNotNil(annotation.title, "The first annotation do not have data")
        }
    }
    
    func testNewsApi() {
        self.newsApi.unwrapData { (news, error) in
            XCTAssertNil(error, "Error is not nilm newsApi")
            XCTAssertNotNil(news, "News are nil")
            let new = news![0]
            XCTAssertNotNil(new.title, "Title is nil")
            XCTAssertNotNil(new.date, "Date is nil")
        }
    }
    
    func testTwitterApi() {
        self.twitterApi.unwrapData { (tweets) in
            XCTAssertNotNil(tweets, "Tweets are nil")
            let tweet = tweets[0]
            XCTAssertNotNil(tweet.author, "Tweet author is nil")
        }
    }
    
    func testWeatherApi() {
        self.weatherApi.unwrapData(self.location) { (weather, error) in
            XCTAssertNil(error, "Error is not nil, weatherApi")
            XCTAssertNotNil(weather, "Weather is nil")
            XCTAssertNotNil(weather.description, "Description weather is nil")
            
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
