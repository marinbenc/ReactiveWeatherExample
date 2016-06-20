//
//  Array+Extensions.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Benčević on 19/06/16.
//  Copyright © 2016 marinbenc. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    /**
     Returns only the unique elements of an Array, in the order they appear in the Array
     
     - note: Items have to be hashable
     */
    var uniqueElements: Array<Element> {
        
        //Using a dictionary because it's faster to look up items in a dictionary than to
        //search trough an array. In other words, array.contans(item:) is O(n) complexity
        var seen: [Element: Bool] = [:]
        
        return self.flatMap { element in
            
            guard seen[element] == nil else {
                //flatMap flattens out nil values
                return nil
            }
            
            seen[element] = true
            return element
        }
    }
}