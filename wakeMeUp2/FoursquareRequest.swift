//
//  Request.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 6/28/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import QuadratTouch
import MapKit

typealias FoursquareResponse = ([[String : AnyObject]]) -> Void
typealias FoursquareData = ([Place], [FoodAnnotation]) -> Void

protocol APIFoursquareProtocol {
    func didRecieveAPIResults(places: [Place], annotations: [FoodAnnotation])
}

struct FoursquareRequest {
    private let session: Session?
    static var delegate: APIFoursquareProtocol?
    static var sharedInstance = FoursquareRequest()
    
    init() {
        let client = Client(clientID: Keys.Foursquare.clientId, clientSecret: Keys.Foursquare.clientSecret, redirectURL: "")
        let configuration = Configuration(client: client)
        Session.setupSharedSessionWithConfiguration(configuration)
        self.session = Session.sharedSession()
    }
    
    func getPlaces(location: CLLocation) {
        unwrapData(location) { (places, annotations) in
            FoursquareRequest.delegate?.didRecieveAPIResults(places, annotations: annotations)
        }
    }
    
    func unwrapData(location: CLLocation, onComplete: FoursquareData) {
        makeRequest(location) {
            (venues) in
            var places: [Place] = []
            var annotations: [FoodAnnotation] = []
            
            for venue: [String: AnyObject] in venues {
                var newPlace: Place = Place()
                
                if let id = venue["id"] as? String {
                    newPlace.id = id
                }
                
                if let name = venue["name"] as? String {
                    newPlace.name = name
                }
                
                if let location = venue["location"] as? [String: AnyObject] {
                    if let longitude = location["lng"] as? Float {
                        newPlace.longitude = longitude
                    }
                    
                    if let latitude = location["lat"] as? Float {
                        newPlace.latitude = latitude
                    }
                    
                    if let address = location["formattedAdress"] as? [String] {
                        newPlace.address = address.joinWithSeparator(" ")
                    }
                    
                    places.append(newPlace)
                    let annotation = FoodAnnotation(title: newPlace.name, subtitle: newPlace.address, coordinate: newPlace.coordinate)
                    annotations.append(annotation)
                }
            }
            onComplete(places, annotations)
        }
    }
    
    private func makeRequest(location: CLLocation, onCompletion: FoursquareResponse) {
        var parameters = location.parameters()
        parameters += [Parameter.categoryId: "4d4b7105d754a06374d81259"]
        parameters += [Parameter.radius: "2000"]
        parameters += [Parameter.limit: "50"]
        let searchTask = session?.venues.search(parameters) {
            (result) -> Void in
            guard let response = result.response else {
                return
            }
            guard let venues = response["venues"] as? [[String: AnyObject]] else {
                return
            }
            onCompletion(venues)
        }
        searchTask?.start()
    }
}


extension CLLocation {
    func parameters() -> [String: String] {
        let ll = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let llAcc = "\(self.horizontalAccuracy)"
        let alt = "\(self.altitude)"
        let altAcc = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll: ll,
            Parameter.llAcc: llAcc,
            Parameter.alt: alt,
            Parameter.altAcc: altAcc
        ]
        return parameters
    }
}



