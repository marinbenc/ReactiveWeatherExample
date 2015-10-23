//
//  ForecastTableViewCell.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 17/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
	
	struct Constants {
		static let baseImageURL = "http://openweathermap.org/img/w/"
		static let imageExtension = ".png"
	}
	
	var forecast:WeatherForecast? {
		didSet {
			updateCell()
		}
	}
	
	
	@IBOutlet weak var dateLabel: UILabel!
	
	@IBOutlet weak var cityDegreesLabel: UILabel!
	@IBOutlet weak var weatherMessageLabel: UILabel!
	@IBOutlet weak var weatherImageOutlet: UIImageView!
	
	func updateCell() {
		if let forecastToShow = forecast {
			let formatter = NSDateFormatter()
			formatter.dateStyle = .MediumStyle
			formatter.timeStyle = .ShortStyle
			formatter.setLocalizedDateFormatFromTemplate("h a")
			dateLabel.text = formatter.stringFromDate(forecastToShow.date)
			
			if let temp = forecastToShow.temp {
				cityDegreesLabel.text = "\(temp)°C"
			}
			weatherMessageLabel.text = forecastToShow.description
		
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
				if let data = NSData(contentsOfURL: NSURL(string: Constants.baseImageURL + forecastToShow.imageID! + Constants.imageExtension)!) {
					if let image = UIImage(data: data) {
						dispatch_async(dispatch_get_main_queue()) { () -> Void in
							self.weatherImageOutlet.image = image
						}
					}
				}
			}
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
		updateCell()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
