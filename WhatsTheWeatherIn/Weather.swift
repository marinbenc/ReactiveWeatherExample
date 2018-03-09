//
//  WeatherAPI.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 11/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Forecast {
    
    let date: Date
    let imageID: String
    let temp: Float
    let description: String
    
    init?(json: JSON) {
        
        guard let
            timestamp = json["dt"].double,
            let imageID = json["weather"][0]["icon"].string,
            let temp = json["main"]["temp"].float,
            let description = json["weather"][0]["description"].string
        else {
            return nil
        }
        
        self.date = Date(timeIntervalSince1970: timestamp)
        self.imageID = imageID
        self.temp = temp
        self.description = description
    }
}

struct Weather {
	
	let cityName: String
    let forecasts: [Forecast]
	
	var currentWeather: Forecast {
        //forecasts will never be empty, see init
        return forecasts[0]
	}
	
	init?(json: JSON) {
        
        guard let
            cityName = json["city"]["name"].string,
            let forecastData = json["list"].array
        else {
            return nil
        }
		
		self.cityName = cityName
        
        let forecasts = forecastData.flatMap(Forecast.init)
        guard !forecasts.isEmpty else {
            return nil
        }
        
        self.forecasts = forecasts
	}
}
