
//
//  Created by Marin Bencevic on 12/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift





class WeatherViewController: UIViewController {
	
	struct Constants {
		static let unknownTempMessage = "Unknown temp"
		static let unknownWeatherMessage = "Unknown weather"
	}
	
	func updateUIWithWeather(weather: Weather) {
		cityNameLabel.text = weather.cityName
		
		if let temp = weather.temp {
			cityDegreesLabel.text = "\(temp)°C"
		} else {
			cityDegreesLabel.text = Constants.unknownTempMessage
		}
		
		if let weatherMessage = weather.weatherString {
			weatherMessageLabel.text = weatherMessage
		} else {
			weatherMessageLabel.text = Constants.unknownWeatherMessage
		}
		
		if let imageURL = weather.imageURL {
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
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let request = cityTextField.rx_text
		.debounce(0.3, scheduler: MainScheduler.sharedInstance)
		.map { searchText in
			return getJsonRequest(searchText)
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
				self.updateUIWithWeather(weather)
			}
		}
		.addDisposableTo(disposeBag)
	}
}
