//
//  WeatherTableViewController.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 17/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift



class WeatherTableViewController: UITableViewController {

	struct Constants {
		static let unknownTempMessage = "Unknown temp"
		static let unknownWeatherMessage = "Unknown weather"
	}
	
	
	//MARK: User interface
	
	func updateCurrentWeatherWithWeather(weather: Weather) {
		cityNameLabel.text = weather.cityName
		
		if let temp = weather.currentWeather?.temp {
			cityDegreesLabel.text = "\(temp)°C"
		} else {
			cityDegreesLabel.text = Constants.unknownTempMessage
		}
		
		if let weatherMessage = weather.currentWeather?.description {
			weatherMessageLabel.text = weatherMessage
			if weatherMessage.containsString("rain") {
				backgroundImageOutlet.image = UIImage(named: "raining") 
			} else if weatherMessage.containsString("cloud") {
				backgroundImageOutlet.image = UIImage(named: "cloudy")
			} else if weatherMessage.containsString("sun") {
				backgroundImageOutlet.image = UIImage(named: "sunny")
			}
		} else {
			weatherMessageLabel.text = Constants.unknownWeatherMessage
		}
		
		if let imageURL = weather.currentWeather?.imageURL {
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
				if let data = NSData(contentsOfURL: imageURL) {
					if let image = UIImage(data: data) {
						dispatch_async(dispatch_get_main_queue()) { () -> Void in
							self.weatherImageOutlet.image = image
						}
					}
				}
			}
		}
	}
	
	func resetUI() {
		cityDegreesLabel.text = Constants.unknownTempMessage
		weatherMessageLabel.text = Constants.unknownWeatherMessage
	}
	
	
	
	let disposeBag = DisposeBag()
	
	@IBOutlet weak var cityTextField: UITextField!
	@IBOutlet weak var cityNameLabel: UILabel!
	@IBOutlet weak var cityDegreesLabel: UILabel!
	@IBOutlet weak var weatherMessageLabel: UILabel!
	@IBOutlet weak var weatherImageOutlet: UIImageView!
	@IBOutlet weak var backgroundImageOutlet: UIImageView!
	
	@IBOutlet weak var weatherView: UIView! { //table view header
		didSet {
			weatherView.bounds.size = UIScreen.mainScreen().bounds.size
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let viewModel = WeatherTableViewModel(searchTextLabel: cityTextField)
		
		let request = cityTextField.rx_text
			.debounce(0.3, scheduler: MainScheduler.sharedInstance)
			.map { searchText in
				return viewModel.getJsonRequest(searchText)
			}
			.shareReplay(1)
		
		let weatherData = request
			.map { request in
				return NSURLSession.sharedSession().rx_JSON(request!)
			}
			.switchLatest()
			.shareReplay(1)
		
		weatherData
			.subscribeNext { data in
				let weather = Weather(jsonObject: data)
				dispatch_async(dispatch_get_main_queue()) { () -> Void in
					self.weatherImageOutlet.image = nil
					self.backgroundImageOutlet.image = nil
					self.updateCurrentWeatherWithWeather(weather)
					self.forecast = weather.forecast
					self.tableView.reloadData()
				}
			}
			.addDisposableTo(disposeBag)
	}


	
    // MARK: - Table view data source
	
	//TODO: Add forecast
	//TODO: Fix space crashing app
	
	var forecast = [WeatherForecast]()
	
	var months:[(String, Int)] {
		var monthsToReturn = [String]()
		var monthCounts = [Int]()
		var count = 1
		
		for weather in forecast {
			let formatter = NSDateFormatter()
			formatter.setLocalizedDateFormatFromTemplate("MMM d")
			let timeString = formatter.stringFromDate(weather.date)
			
			if !monthsToReturn.contains(timeString) {
				if !monthsToReturn.isEmpty {
					monthCounts.append(count)
					count = 1
				}
				monthsToReturn.append(timeString)
			} else {
				count++
			}
		}
		
		let returnArray = Array(zip(monthsToReturn, monthCounts))
		print(returnArray)
		
		return returnArray
	}

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return months.count
    }
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return months[section].0
	}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return months[section].1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> ForecastTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("forecastCell", forIndexPath: indexPath) as? ForecastTableViewCell
		
		var index = 0
		for var i = 0; i < indexPath.section; i++ {
			index += tableView.numberOfRowsInSection(i)
		}
		index += indexPath.row
		
		cell!.forecast = forecast[index]

        return cell!
    }
}
