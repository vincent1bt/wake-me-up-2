//
//  Weather.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/3/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON

enum TypeOfImage: String {
    case Clouds = "02"
    case ScatteredClouds = "03"
    case BrokenClouds = "04"
    case ShowerRain = "09"
    case Rain = "10"
    case Thunderstorm = "11"
    case Snow = "13"
    case Mist = "50"
}

protocol APIWeatherProtocol {
    func didRecieveAPIResults(weatherObject: Weather)
}

typealias WeatherResponse = (Weather, NSError?) -> Void


struct WeatherRequest {
    let request: Request = Request()
    let utils: Utils = Utils()
    var delegate: APIWeatherProtocol?
    
    func getWeather(location: CLLocation) {
        self.unwrapData(location) { (weather, error) in
            self.delegate?.didRecieveAPIResults(weather)
        }
    }
    
    func unwrapData(location: CLLocation, onComplete: WeatherResponse) {
        let endPoint = "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&APPID=\(Keys.Weather.key)&units=metric&lang=es"
        request.makeRequest(endPoint) { (json, error) in
            guard let jsonObject = json else {
                return
            }
            let degrees = (jsonObject["main"].dictionaryValue)["temp"]?.numberValue
            let description = (jsonObject["weather"].arrayValue.first)?.dictionaryValue["description"]?.stringValue
            let icon = (jsonObject["weather"].arrayValue.first)?.dictionaryValue["icon"]?.stringValue
            
            var weatherObject = Weather()
            if degrees != nil {
                weatherObject.degrees = "\(Int(degrees!))°c"
            }
            
            if description != nil {
                weatherObject.description = description!.capitalizedString
            }
            
            if let iconName = self.getIcon(icon) {
                weatherObject.icon = iconName
            }
            let date = NSDate()
            weatherObject.date = self.utils.dateToString(date)
            onComplete(weatherObject, nil)
        }
    }
    
    private func getIcon(icon: String?) -> String? {
        if icon != nil {
            if icon == "01d" {
                return "sunHd"
            } else if icon == "01n" {
                return "nightHd"
            } else {
                let image = (icon! as NSString).substringWithRange(NSMakeRange(0, 2))
                if let possibleIcon = TypeOfImage(rawValue: image) {
                    switch possibleIcon {
                    case .Clouds, .BrokenClouds, .ScatteredClouds:
                        return "cloudsHd"
                    case .Rain, .ShowerRain:
                        return "rainHd"
                    case .Mist:
                        return "mistHd"
                    case .Thunderstorm:
                        return "thunderstormHd"
                    case .Snow:
                        return "snowHd"
                    }
                }
            }
        }
        return nil
    }
}