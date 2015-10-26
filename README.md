# ReactiveWeatherExample
A simple iOS weather app using the MVVM pattern and RxSwift framework.

#How it works
There's a UITextField in the ViewController which sets a searchText property in the ViewModel once it's changed. The ViewModel then iniates a JSON request for weather data from openweathermap.org, and creates a new Weather object, which acts as the model.

Once the Weather object is set, properties in the ViewModel are set accordingly. Since outlets in the ViewController are bound to properties in the ViewModel, they get set automatically.


RxSwift: https://github.com/ReactiveX/RxSwift  
OpenWeatherMap: https://openweathermap.org
Alamofire: https://github.com/Alamofire/Alamofire
