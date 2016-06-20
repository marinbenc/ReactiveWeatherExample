//
//  String+Extensions.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Benčević on 16/05/16.
//  Copyright © 2016 marinbenc. All rights reserved.
//

import Foundation

extension String {
    
    var withPercentEncodedSpaces: String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "%20")
    }
    
}