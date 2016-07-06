//
//  Places.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 6/29/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import MapKit

struct Place {
    var id: String?
    var name: String?
    var longitude: Float?
    var latitude: Float?
    var adress: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(self.latitude!), longitude: Double(self.longitude!))
    }
}