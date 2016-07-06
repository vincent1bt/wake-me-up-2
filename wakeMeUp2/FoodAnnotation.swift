//
//  FoodAnotation.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 6/29/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import MapKit


class FoodAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}
