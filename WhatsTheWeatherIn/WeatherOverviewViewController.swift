//
//  WeatherTableViewController.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 17/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


//MARK: - ForecastModel

///Represents a presentation layer model for a Forecast, to be displayed in a UITableViewCell
struct ForecastModel {
    let time: String
    let description: String
    let temp: String
}


//MARK: -
//MARK: - WeatherOverviewViewController
final class WeatherOverviewViewController: UIViewController {
    
    
    //MARK: - Dependencies
    
    private var viewModel: WeatherViewModel!
    private let disposeBag = DisposeBag()
    
    
	//MARK: - Outlets
    
    @IBOutlet weak var forecastsTableView: UITableView!
    
	@IBOutlet weak var cityTextField: UITextField!
	
    @IBOutlet weak var cityNameLabel: UILabel!
	@IBOutlet weak var cityDegreesLabel: UILabel!
	@IBOutlet weak var weatherMessageLabel: UILabel!
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherBackgroundImageView: UIImageView!
    
    ///table view header (current weather display)
    @IBOutlet weak var weatherView: UIView!
	
	//MARK: - Lifecycle
    
    private func addBindsToViewModel(viewModel: WeatherViewModel) {
        
        cityTextField.rx_text
            .bindTo(viewModel.searchText)
            .addDisposableTo(disposeBag)
        
        viewModel.cityName
            .bindTo(cityNameLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel.temp
            .bindTo(cityDegreesLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel.weatherDescription
            .bindTo(weatherMessageLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel.weatherImageData
            .map(UIImage.init)
            .bindTo(weatherIconImageView.rx_image)
            .addDisposableTo(disposeBag)
        
        viewModel.weatherBackgroundImage
            .map { $0.image }
            .bindTo(weatherBackgroundImageView.rx_image)
            .addDisposableTo(disposeBag)
        
        viewModel.cellData
            .bindTo(forecastsTableView.rx_itemsWithDataSource(self))
            .addDisposableTo(disposeBag)
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        forecastsTableView.delegate = self
        
        viewModel = WeatherViewModel(weatherService: WeatherAPIService())
		addBindsToViewModel(viewModel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Set Forecast views hight to cover the whole screen

        forecastsTableView.tableHeaderView?.bounds.size.height = view.bounds.height
        //A dirty UIKit bug workaround to force a UI update on the TableView's header
        forecastsTableView.tableHeaderView = forecastsTableView.tableHeaderView
    }
    
    //MARK: - TableViewData
    
    //The data to update the tableView with. These is a better way to update the
    //tableView with RxSwift, please see 
    //https://github.com/ReactiveX/RxSwift/tree/master/RxExample
    //However this implementation is much simpler
    private var tableViewData: [(day: String, forecasts: [ForecastModel])]? {
        didSet {
            forecastsTableView.reloadData()
        }
    }
}


//MARK: - Table View Data Source & Delegate
extension WeatherOverviewViewController: UITableViewDataSource, RxTableViewDataSourceType {
    
    //Gets called on tableView.rx_elements.bindTo methods
    func tableView(tableView: UITableView, observedEvent: Event<[(day: String, forecasts: [ForecastModel])]>) {
        
        switch observedEvent {
        case .Next(let items):
            tableViewData = items
        case .Error(let error):
            print(error)
            presentError()
        case .Completed:
            tableViewData = nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableViewData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData?[section].day
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData?[section].forecasts.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("forecastCell", forIndexPath: indexPath) as! ForecastTableViewCell
        
        guard let forecast = tableViewData?[indexPath.section].forecasts[indexPath.row] else {
            return cell
        }
        
        cell.cityDegreesLabel.text = forecast.temp
        cell.dateLabel.text = forecast.time
        cell.weatherMessageLabel.text = forecast.description
        return cell
    }
}

extension WeatherOverviewViewController: UITableViewDelegate {}
