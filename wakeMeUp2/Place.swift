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
    var id: String = "No Id"
    var name: String = "No name"
    var longitude: Float = 0.0
    var latitude: Float = 0.0
    var address: String = "No address"
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(self.latitude), longitude: Double(self.longitude))
    }
}