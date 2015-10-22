//
//  WeatherTableViewModel.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 18/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift

extension NSDate {
	var dayString:String {
		let formatter = NSDateFormatter()
		formatter.setLocalizedDateFormatFromTemplate("d M")
		return formatter.stringFromDate(self)
	}
}

class MVVMWeatherTableViewModel {
	
	struct Constants {
		static let baseURL = "http://api.openweathermap.org/data/2.5/forecast?q="
		static let urlExtension = "&units=metric&type=like&APPID=6a700a1e919dc96b0a98901c9f4bec47"
		static let baseImageURL = "http://openweathermap.org/img/w/"
		static let imageExtension = ".png"
	}
	
	var disposeBag = DisposeBag()
	
	
	
	//MARK: Model
	
	var weather: Weather? {
		didSet {
			if weather?.cityName != nil {
				updateModel()
			}
		}
	}
	
	
	
	//MARK: UI data source
	
	var cityName = PublishSubject<String?>()
	var degrees = PublishSubject<String?>()
	var weatherDescription = PublishSubject<String?>()
	private var forecast:[WeatherForecast]?
	var weatherImage = PublishSubject<UIImage?>()
	var backgroundImage = PublishSubject<UIImage?>()
	var tableViewData = PublishSubject<[(String, [WeatherForecast])]>()
	
	
	
	func updateModel() {
		sendNext(cityName, weather?.cityName)
		if let temp = weather?.currentWeather?.temp {
			sendNext(degrees, String(temp))
		}
		sendNext(weatherDescription, weather?.currentWeather?.description)
		if let id = weather?.currentWeather?.imageID {
			setWeatherImageForImageID(id)
			setBackgroundImageForImageID(id)
		}
		forecast = weather?.forecast
		if forecast != nil {
			sendTableViewData()
		}
	}
	
	//Parses the forecast data into an array of (date, forecasts for that day) tuple
	func sendTableViewData() {
		if let currentForecast = forecast {
			
			var forecasts = [[WeatherForecast]]()
			var days = [String]()
			days.append(NSDate(timeIntervalSinceNow: 0).dayString)
			var tempForecasts = [WeatherForecast]()
			for forecast in currentForecast {
				if days.contains(forecast.date.dayString) {
					tempForecasts.append(forecast)
				} else {
					days.append(forecast.date.dayString)
					forecasts.append(tempForecasts)
					tempForecasts.removeAll()
					tempForecasts.append(forecast)
				}
			}
			
			sendNext(tableViewData, Array(zip(days, forecasts)))
		}
	}
	
	func setWeatherImageForImageID(imageID: String) {
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
			if let url = NSURL(string: Constants.baseImageURL + imageID + Constants.imageExtension) {
				if let data = NSData(contentsOfURL: url) {
					dispatch_async(dispatch_get_main_queue()) { () -> Void in
						sendNext(self.weatherImage, UIImage(data: data))
					}
				}
			}
		}
	}
	
	//TODO:
	func setBackgroundImageForImageID(imageID: String) {
	}
	
	
	
	//MARK: Lifecycle
	
	var searchText:String? {
		didSet {
			if let text = searchText {
				request = just(getJsonRequest(text))
			}
		}
	}
	
	var request: Observable<NSURLRequest?> {
		didSet {
			request
				.subscribeNext { myRequest in
					if let r = myRequest {
						self.json = just(NSURLSession.sharedSession().rx_JSON(r))
					}
				}
				.addDisposableTo(disposeBag)
		}
	}
	
	var json: Observable<AnyObject!> {
		didSet {
			json = request
				.map({ myRequest in
					return NSURLSession.sharedSession().rx_JSON(myRequest!)
				})
				.switchLatest()
				.shareReplay(1)
			
			json
				.subscribeNext({ json in
					self.weather = Weather(jsonObject: json)
				})
				.addDisposableTo(disposeBag)
		}
	}
	
	init () {
		request = just(nil)
		json = just("")
		updateModel()
	}
	
	func getJsonRequest(string: String)-> NSURLRequest {
		let stringWithoutSpaces = string.stringByReplacingOccurrencesOfString(" ", withString: "%20")
		let url = NSURL(string: Constants.baseURL + "\(stringWithoutSpaces)" + Constants.urlExtension)
		
		return NSURLRequest(URL: url!)
	}
}