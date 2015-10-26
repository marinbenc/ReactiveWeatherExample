//
//  WeatherAPI.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 11/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias JSONDictionary = [String: AnyObject]
typealias WeatherForecast = (date: NSDate, imageID: String?, temp: Double?, description: String?)

class Weather {
	struct Constants {
		static let baseURL = "http://api.openweathermap.org/data/2.5/forecast?q="
		static let urlParams = "&units=metric&type=like&APPID=6a700a1e919dc96b0a98901c9f4bec47"
		static let baseImageURL = "http://openweathermap.org/img/w/"
		static let imageExtension = ".png"
	}
	
	var cityName:String?
	var forecast = [WeatherForecast]()
	
	var currentWeather:WeatherForecast? {
		if !forecast.isEmpty {
			return forecast[0]
		} else {
			return nil
		}
	}
	
	//TODO: Cash last request
	
	init(jsonObject: AnyObject) {
		let json = JSON(jsonObject)
		
		self.cityName = json["city"]["name"].stringValue
		if let forecastArray = json["list"].array {
			for item in forecastArray {
				let itemForecast = (date: NSDate(timeIntervalSince1970: NSTimeInterval(item["dt"].intValue)),
					imageID: item["weather"][0]["icon"].string,
					temp: item["main"]["temp"].double,
					description: item["weather"][0]["description"].string)
				
				forecast.append(itemForecast)
			}
		}
	}
}
