//
//  WeatherSearchViewController.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 03/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift


typealias City = (city: String, weather: String)
typealias WeatherResults = Observable<[City]>

//View model
class WeatherService {
	
	//Model
	let availableCities:[City] = [(city: "New Orleans", weather: "A bit windy"),
								  (city: "New York", weather: "Cloudy with a chance of meatballs")]
	
	func foundCitiesThatMatchSubstr(substr: String)-> WeatherResults {
		
		var possibleCities = [City]()
		
		for city in availableCities {
			if city.city.lowercaseString.containsString(substr.lowercaseString) {
				possibleCities.append(city)
			}
		}
		
		return just(possibleCities)
	}
}


//View
class WeatherSearchViewController: UIViewController {
	
	let service = WeatherService()
	let disposeBag = DisposeBag()
	
	struct Constants {
		static let newYorkColor = UIColor.greenColor()
		static let everyThingElseColor = UIColor.redColor()
	}

	@IBOutlet weak var cityTextField: UITextField!
	@IBOutlet weak var weatherResultLabel: UILabel!
	
	func bindResultToLabel(weather: WeatherResults, label: UILabel) {
		weather
			.subscribeNext { weather in
				label.text = !weather.isEmpty ? weather.description : "City not found"
				label.textColor = !weather.isEmpty ? Constants.newYorkColor : Constants.everyThingElseColor
				}
			.addDisposableTo(disposeBag)
	}
	
    override func viewDidLoad() {
		let city = cityTextField.rx_text
			.map { city in
				return self.service.foundCitiesThatMatchSubstr(city)
				}
			.switchLatest()
			.shareReplay(1)
		
		bindResultToLabel(city, label: weatherResultLabel)
		
        super.viewDidLoad()
    }
}
