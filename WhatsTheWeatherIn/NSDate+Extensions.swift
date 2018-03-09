//
//  NSDate+Extensions.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Benčević on 16/05/16.
//  Copyright © 2016 marinbenc. All rights reserved.
//

import Foundation

extension Date {
    
    ///Returns the time of a date formatted as "HH:mm" (e.g. 18:30)
    func formattedTime(formatter: DateFormatter)-> String {
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
        return formatter.string(from: self)
    }
    
    ///Returns a string in "d M" format, e.g. 19/9 for June 19.
    func formattedDay(formatter: DateFormatter)-> String {
        //the reason formatter is injected is because creating an
        //NSDateFormatter instance is pretty expensive
        formatter.setLocalizedDateFormatFromTemplate("d M")
        return formatter.string(from: self)
    }
    
    ///Returns the week day of the NSDate, e.g. Sunday.
    func dayOfWeek(formatter: DateFormatter)-> String {
        //the reason formatter is injected is because creating an
        //NSDateFormatter instance is pretty expensive
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter.string(from: self)
    }
}


//MARK: - Comparable

extension Date{

    static func ==(lhs: Date, rhs: Date) -> Bool {
    //return lhs.isEqualToDate(rhs)
    return  lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

    static public func <(lhs: Date, rhs: Date) -> Bool {
//    return lhs.earlierDate(rhs) === lhs
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}
    
}
