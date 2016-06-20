//
//  WeatherAPIService.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Benčević on 16/05/16.
//  Copyright © 2016 marinbenc. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire
import SwiftyJSON

class WeatherAPIService {
    
    private struct Constants {
        static let APPID = "6a700a1e919dc96b0a98901c9f4bec47"
        static let baseURL = "http://api.openweathermap.org/"
    }
    
    enum ResourcePath: String {
        case Forecast = "data/2.5/forecast"
        case Icon = "img/w/"
        
        var path: String {
            return Constants.baseURL + rawValue
        }
    }
    
    enum APIError: ErrorType {
        case CannotParse
    }
    
    func search(withCity city: String)-> Observable<Weather> {
        
        let encodedCity = city.withPercentEncodedSpaces
        
        let params: [String: AnyObject] = [
            "q": encodedCity,
            "units": "metric",
            "type": "like",
            "APPID": Constants.APPID
        ]
        
        return request(.GET, ResourcePath.Forecast.path, parameters: params, encoding: .URLEncodedInURL)
            .rx_JSON()
            .map(JSON.init)
            .flatMap { json -> Observable<Weather> in
                guard let weather = Weather(json: json) else {
                    return Observable.error(APIError.CannotParse)
                }
                
                return Observable.just(weather)
            }
    }
    
    func weatherImage(forID imageID: String)-> Observable<NSData> {
        return request(.GET, ResourcePath.Icon.path + imageID + ".png").rx_data()
    }
}