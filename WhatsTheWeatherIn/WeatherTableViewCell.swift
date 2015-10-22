//
//  WeatherTableViewCell.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 10/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
	
	var city:City? {
		didSet {
			reloadData()
		}
	}
	
	func reloadData() {
		if let myCity = city {
			titleLabel.text = myCity.city
			subtitleLabel.text = myCity.weather
		}
	}
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
		
		reloadData()
    }

}
