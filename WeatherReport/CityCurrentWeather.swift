//
//  CityCurrentWeather.swift
//  WeatherReport
//
//  Created by zhangyunchen on 16/1/27.
//  Copyright © 2016年 zhangyunchen. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CityCurrentWeather: UIViewController,CLLocationManagerDelegate {
    
    var weatherService = OpenWeatherMapService()
    var locationManager = CLLocationManager()
    var sharedContext: NSManagedObjectContext{
        return CoreDataStack.sharedInstance().managedObjectContext
    }
    
    var currentWeather:CurrentWeather?
    var currentLocation:CLLocation?
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        getSavedLocation()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //更新距离
        locationManager.distanceFilter = 100
        
        if locationManager.respondsToSelector("requestAlwaysAuthorization") {
            print("requestAlwaysAuthorization")
            locationManager.requestAlwaysAuthorization()
        }
        
        if (CLLocationManager.locationServicesEnabled())
        {
            //允许使用定位服务的话，开启定位服务更新
            locationManager.startUpdatingLocation()
            print("定位开始")
        }


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView(){
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("CurrentWeather", inManagedObjectContext: sharedContext)
        fetchRequest.entity = entityDescription
        do{
            let results = try sharedContext.executeFetchRequest(fetchRequest)

            let currentWeathers = results as! [CurrentWeather]
            if currentWeathers.count > 0 {
                currentWeather = currentWeathers[0]
                self.locationLabel.text = currentWeather!.cityName
                self.weatherLabel.text = currentWeather!.weather
                self.tempLabel.text = String(currentWeather!.temp)

            }
        } catch {
            
        }
        
    }
    
    func getSavedLocation(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let latitude = defaults.doubleForKey("latitude")
        let longitude = defaults.doubleForKey("longitude")
        currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        print("get saved location is \(currentLocation)")
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        currentLocation = locations.last!
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble((currentLocation?.coordinate.latitude)!, forKey: "latitude")
        defaults.setDouble((currentLocation?.coordinate.longitude)!, forKey: "longitude")
        weatherService.getWeatherInfoWithLocation(OpenWeatherMapService.Method.current,location: currentLocation!) { (data, errorString) -> Void in
            
            if let errorString = errorString {
                print("there is some error and error is \(errorString)")
            }
            
            if let data = data as? NSDictionary {
                self.sharedContext.performBlock({ () -> Void in
                    let fetchRequest = NSFetchRequest()
                    let entityDescription = NSEntityDescription.entityForName("CurrentWeather", inManagedObjectContext: self.sharedContext)
                    fetchRequest.entity = entityDescription
                    do{
                        let results = try self.sharedContext.executeFetchRequest(fetchRequest)
                        
                        let currentWeathers = results as! [CurrentWeather]
                        if currentWeathers.count > 0 {
                            for currentWeather in currentWeathers {
                                self.sharedContext.deleteObject(currentWeather as! CurrentWeather)
                            }
                            CoreDataStack.sharedInstance().saveContext()
                        }
                    } catch {
                        
                    }
                })
                
                let entity = NSEntityDescription.entityForName("CurrentWeather", inManagedObjectContext: self.sharedContext)
                let currentWeather = CurrentWeather(entity:entity!,insertIntoManagedObjectContext: self.sharedContext)
                
                currentWeather.cityName = data["name"] as! String
                if let weather = data["weather"] as? [NSDictionary] {
                    let weatherCondition = weather[0]["id"] as! Int
                    let weatherIcon = weather[0]["icon"] as! String
                    
                    currentWeather.weather = WeatherIcon(condition: weatherCondition, iconString: weatherIcon).iconText
                }
                if let main = data["main"] as? NSDictionary {
                    
                    let temp = main["temp"] as! Double
                    
                    
                    currentWeather.temp = String(Utils.getFahrenheit(temp)) + "°C"
                }
                self.sharedContext.performBlock({ () -> Void in
                    CoreDataStack.sharedInstance().saveContext()
                })
                
                self.currentWeather = currentWeather
                
                dispatch_async(dispatch_get_main_queue()){
                    self.locationLabel.text = currentWeather.cityName
                    self.weatherLabel.text = currentWeather.weather
                    self.tempLabel.text = currentWeather.temp

                }
            }
        }
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showForecast" {
            let forecastController = segue.destinationViewController as! ViewController
            forecastController.currentWeather = currentWeather
            forecastController.currentLocation = currentLocation
            locationManager.stopUpdatingLocation()
            
        }
    }

}
