//
//  WeatherViewModel.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 18/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit
import RxSwift

final class WeatherViewModel {
    
    //MARK: - Dependecies
    
    private let weatherService: WeatherAPIService
    private let disposeBag = DisposeBag()
    private let formatter = DateFormatter()
    
    
    //MARK: - Model
    
    private let weather: Observable<Weather>
    
    ///The name of the currently displayed city.
    let cityName: Observable<String>
    
    ///A short description of the current weather
    let weatherDescription: Observable<String>
    
    ///A formatted string of the current temperature for the currently displayed city.
    let temp: Observable<String>
    
    ///The data for a small image (e.g. clouds) representing the current weather
    let weatherImageData: Observable<Data>
    
    ///Background image to display for a certain current weather
    let weatherBackgroundImage: Observable<WeatherBackgroundImage>
    
    ///Data for a table in the format of (day, forecasts for that day).
    ///Days represent sections, while foreacasts represent cells.
    var cellData: Observable<[(day: String, forecasts: [ForecastModel])]> {
        return weather.map(self.cells)
    }
    
    ///Sending new elements trough this property starts a search request.
    var searchText = Variable<String>("")
    
    
    //MARK: - Set up
    
    init(weatherService: WeatherAPIService) {
        
        //Initialise dependencies
        
        self.weatherService = weatherService
        
        //Subscribe weather to the searchText Observable,
        //get the latest value and map it to an Observable<Weather>
        weather = searchText.asObservable()
            //wait 0.3 s after the last value to fire a new value
            .debounce(0.3, scheduler: MainScheduler.instance)
            //only fire if the value is different than the last one
            .distinctUntilChanged()
            //convert Observable<String> to Observable<Weather>
            .flatMapLatest { searchString -> Observable<Weather> in
                
                guard !searchString.isEmpty else {
                    //flatMapLatest will flatten empty Observables
                    //much like regular flatMap will flatten nil values
                    return Observable.empty()
                }
                
                return weatherService.search(withCity: searchString)
            }
            //make sure all subscribers use the same exact subscription
            .share(replay: 1)
        
        
        //Initialise observers
        
        cityName = weather
            .map { $0.cityName }
        
        temp = weather
            .map { "\($0.currentWeather.temp)" }
        
        weatherDescription = weather
            .map { $0.currentWeather.description }
        
        weatherImageData = weather
            .map { $0.currentWeather.imageID }
            .flatMap(weatherService.weatherImage)
        
        weatherBackgroundImage = weather
            .map { $0.currentWeather.imageID }
            .map { return WeatherBackgroundImage(imageID: $0)! }
    }
    
    
    //MARK: - Private methods
    
    ///Parses the forecast data into an array of (date, forecasts for that day) tuple.
    private func cells(from weather: Weather)-> [(day: String, forecasts: [ForecastModel])] {
        
        //There's probably a better way to write this.
        
        func dateTimestampFromDate(date: Date)-> String {
            formatter.dateFormat = "YYMMdd HHmm"
            return formatter.string(from: date)
        }
        
        func dayTimestampFromDateTimstamp(timestamp: String)-> String {
            return String(timestamp.split(separator: " ")[0])
        }
        
        let allTimestamps = weather.forecasts
            .map { $0.date }
            .map(dateTimestampFromDate)
        
        let uniqueDayTimestamps = allTimestamps
            .map(dayTimestampFromDateTimstamp)
            .uniqueElements
        
        let forecastsForDays = uniqueDayTimestamps.map { day in
            return weather.forecasts.filter { forecast in
                let forecastTimestamp = dateTimestampFromDate(date: forecast.date)
                let dayOfForecast = dayTimestampFromDateTimstamp(timestamp: forecastTimestamp)
                
                return dayOfForecast == day
            }
        }
        
        let forecastModels = forecastsForDays.map { forecasts in
            return forecasts.map(forecastModel)
        }
        
        let dayStrings = weather.forecasts
            .map { $0.date.dayOfWeek(formatter: formatter) }
            .uniqueElements
        
        //Combine those two Arrays into an Array of tuples
        return Array( zip(dayStrings, forecastModels))
    }
    
    private func forecastModel(from forecast: Forecast)-> ForecastModel {
        return ForecastModel(
            time: forecast.date.formattedTime(formatter: formatter),
            description: forecast.description,
            temp: "\(forecast.temp)C")
    }
	
}
