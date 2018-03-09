
platform :ios, "10.0"
use_frameworks!

target 'WhatsTheWeatherIn' do
    pod 'Alamofire', '~> 4.6'
    pod 'SwiftyJSON'
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
    pod 'Action'
    pod 'RxBlocking'
    pod 'RxAlamofire'
end

target 'WhatsTheWeatherInTests' do

end

target 'WhatsTheWeatherInUITests' do

end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
