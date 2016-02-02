//
//  ViewController.swift
//  WeatherReport
//
//  Created by zhangyunchen on 16/1/24.
//  Copyright © 2016年 zhangyunchen. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UITableViewController {
    
    var weatherService = OpenWeatherMapService()
    var currentWeather:CurrentWeather?
    var currentLocation:CLLocation?
    var sharedContext: NSManagedObjectContext{
        return CoreDataStack.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController:NSFetchedResultsController = {
        var fetchRequest = NSFetchRequest(entityName: "Forecast")
//        let predicate = NSPredicate(format: "currentWeather == %@", self.currentWeather!)
//        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"date",ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        print("fetched results have been init")
        return fetchedResultsController
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        getForecast()
        do {
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("error: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("weatherCell")! as! WeatherCell
        let forecast = fetchedResultsController.objectAtIndexPath(indexPath) as! Forecast
        cell.weather.text = forecast.weather
        cell.temp.text = forecast.tempDescription
        cell.date.text = forecast.date
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects?.count == nil {
            print("there is no fetched results")
            return 0
        }
        print("there should be fetched results and results num is \(fetchedResultsController.fetchedObjects?.count)")
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func getForecast(){
        if let currentLocation = currentLocation {
            weatherService.getWeatherInfoWithLocation(OpenWeatherMapService.Method.forcast,location: currentLocation) { (data, errorString) -> Void in
                
                if let errorString = errorString {
                    print("there is some error and error is \(errorString)")
                }
                
                if let data = data as? NSDictionary {
                    self.sharedContext.performBlock({ () -> Void in
                        
                        if self.fetchedResultsController.fetchedObjects?.count > 0 {
                            for forecast in self.fetchedResultsController.fetchedObjects!  {
                                self.sharedContext.deleteObject(forecast as! Forecast)
                            }
                        }
                        
                        CoreDataStack.sharedInstance().saveContext()
                        
                        let lists = data["list"] as? [NSDictionary]
                        let forecastEntity = NSEntityDescription.entityForName("Forecast", inManagedObjectContext:self.sharedContext)
                        for weather in lists! {
                            
                            let forecast = Forecast(entity: forecastEntity!,insertIntoManagedObjectContext: self.sharedContext)
                            let temp = weather["temp"]!
                            let minTemp = Utils.getFahrenheit(temp["min"] as! Double)
                            let maxTemp = Utils.getFahrenheit(temp["max"] as! Double)
                            forecast.tempDescription = String("\(minTemp)°C ~ \(maxTemp)°C ")
                            
                            if let weather = weather["weather"] as? [NSDictionary] {
                                let weatherCondition = weather[0]["id"] as! Int
                                let weatherIcon = weather[0]["icon"] as! String
                                
                                forecast.weather = WeatherIcon(condition: weatherCondition, iconString: weatherIcon).iconText
                            }
                            
                            forecast.date = Utils.getDate(weather["dt"] as! Double)
                            forecast.currentWeather = self.currentWeather!
                        }
                        CoreDataStack.sharedInstance().saveContext()
                    })
                    
                }
            }
            
        }
    }
    



}

