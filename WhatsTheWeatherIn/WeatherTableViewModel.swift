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

class WeatherTableViewModel {
	
	var disposeBag = DisposeBag()
	var searchText:Observable<String?>
	
	init (searchTextLabel: UITextField) {
		searchText = just(searchTextLabel.text)
		
		searchTextLabel.rx_text
		.debounce(0.3, scheduler: MainScheduler.sharedInstance)
		.subscribeNext({ text in
			print(text)
			self.searchText = just(text)
		})
	}
	
	
	var cityName:String?
	var degrees:String?
	var weatherDescription:String?
	var weatherImage:UIImage?
	var backgroundImage:UIImage?
	
	func getJsonRequest(string: String)-> NSURLRequest? {
		let url = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast?q=" + "\(string)" + "&units=metric&type=like&APPID=6a700a1e919dc96b0a98901c9f4bec47")
		if let searchURL = url {
			return NSURLRequest(URL: searchURL)
		} else {
			return nil
		}
	}
}