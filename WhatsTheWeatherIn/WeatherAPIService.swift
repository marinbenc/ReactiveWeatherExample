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
        static let APPID = "262ace8b6dcc8a4dc5c11bc070f67dc1"
        static let baseURL = "http://api.openweathermap.org/"
    }
    
    enum ResourcePath: String {
        case Forecast = "data/2.5/forecast"
        case Icon = "img/w/"
        
        var path: String {
            return Constants.baseURL + rawValue
        }
    }
    
    enum APIError: Error {
        case CannotParse
    }
    
    func search(withCity city: String)-> Observable<Weather> {
       
        let encodedCity = city.withPercentEncodedSpaces
        
        let params: [String: Any] = [
            "q": encodedCity,
            "units": "metric",
            "type": "like",
            "APPID": Constants.APPID
        ]
        return  requestJSON(.get, ResourcePath.Forecast.path, parameters: params)
            
        .map{
            JSON.init($0.1)
        }
            .flatMap{ json -> Observable<Weather> in
               // print(json)
                guard let weather = Weather(json: json) else {
                    return Observable.empty()
                   // return Observable.error(APIError.CannotParse)
                }
                return Observable.just(weather)
        }

        
    }
    
    func weatherImage(forID imageID: String)-> Observable<Data> {
      
        return requestData(.get, ResourcePath.Icon.path + imageID + ".png").map{$0.1}
        
    }
}
