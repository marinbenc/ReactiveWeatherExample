//
//  WeatherTableViewModel.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 18/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON

import Alamofire

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
	
	
	
	//MARK: UI
	
	var cityName = PublishSubject<String?>()
	var degrees = PublishSubject<String?>()
	var weatherDescription = PublishSubject<String?>()
	private var forecast:[WeatherForecast]?
	var weatherImage = PublishSubject<UIImage?>()
	var backgroundImage = PublishSubject<UIImage?>()
	var tableViewData = PublishSubject<[(String, [WeatherForecast])]>()
	var errorAlertView = PublishSubject<UIAlertView>()
	
	func updateModel() {
		cityName.on(.Next(weather?.cityName))
		if let temp = weather?.currentWeather?.temp {
			degrees.on(.Next(String(temp)))
		}
		weatherDescription.on(.Next(weather?.currentWeather?.description))
		if let id = weather?.currentWeather?.imageID {
			setWeatherImageForImageID(id)
			setBackgroundImageForImageID(id)
		}
		forecast = weather?.forecast
		if forecast != nil {
			sendTableViewData()
		}
	}
	
	func setWeatherImageForImageID(imageID: String) {
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
			if let url = NSURL(string: Constants.baseImageURL + imageID + Constants.imageExtension) {
				if let data = NSData(contentsOfURL: url) {
					dispatch_async(dispatch_get_main_queue()) { () -> Void in
						self.weatherImage.on(.Next(UIImage(data: data)))
					}
				}
			}
		}
	}
	
	//TODO:
	func setBackgroundImageForImageID(imageID: String) {
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
			tableViewData.on(.Next(Array(zip(days, forecasts))))
		}
	}
	
	
	
	//MARK: Weather fetching
	
	var searchText:String? {
		didSet {
			if let text = searchText {
				let urlString = Constants.baseURL + text.stringByReplacingOccurrencesOfString(" ", withString: "%20") + Constants.urlExtension
				
				getWeatherForRequest(urlString)
			}
		}
	}
	
	func getWeatherForRequest(urlString: String) {
		let observable = Alamofire.request(Method.GET, urlString).rx_responseJSON()
		.observeOn(MainScheduler.sharedInstance)
		.subscribe(
			onNext: { json in
				let jsonForValidation = JSON(json)
				if let error = jsonForValidation["message"].string {
					print("got error \(error)")
					self.postError("Error", message: error)
					return
				}
				self.weather = Weather(jsonObject: json)

				},
			onError: { error in
				print("Got error")
				let gotError = error as NSError
				
				print(gotError.domain)
				self.postError("\(gotError.code)", message: gotError.domain)
			})
		.addDisposableTo(disposeBag)
	}
	
	func postError(title: String, message: String) {
		errorAlertView.on(.Next(UIAlertView(title: title,
			message: message,
			delegate: nil,
			cancelButtonTitle: "Okay")))
	}




}