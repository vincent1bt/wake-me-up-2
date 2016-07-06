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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlacesApi() {
        let location = CLLocation(latitude: CLLocationDegrees(19.4993813631165) , longitude: CLLocationDegrees(-96.8489498739627))
        FoursquareRequest.sharedInstance.unwrapData(location) { (places, annotations) in
            XCTAssertNotNil(places, "Places are nil")
            XCTAssertNotNil(annotations, "Annotations are nil")
            let place = places[0]
            let annotation = annotations[0]
            XCTAssertNotEqual(place.id, "No Id")
            XCTAssertNotNil(annotation.title, "The first annotation do not have data")
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
