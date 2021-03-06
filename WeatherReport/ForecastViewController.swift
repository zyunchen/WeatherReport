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

class ForecastViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    
    var weatherService = OpenWeatherMapService()
    var currentWeather:CurrentWeather?
    var currentLocation:CLLocation?
    
    var days:Int?
    
    var sharedContext: NSManagedObjectContext{
        return CoreDataStack.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController:NSFetchedResultsController = {
        var fetchRequest = NSFetchRequest(entityName: "Forecast")
        let predicate = NSPredicate(format: "currentWeather == %@", self.currentWeather!)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"date",ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        print("fetched results have been init")
        return fetchedResultsController
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load done")
        getForecast()
        do {
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print("error: \(error)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if fetchedResultsController.delegate == nil {
            fetchedResultsController.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("there should be fetched results and results num is \(fetchedResultsController.fetchedObjects?.count)")
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
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if let currentLocation = currentLocation {
            weatherService.getWeatherInfoWithLocation(OpenWeatherMapService.Method.forcast,location: currentLocation,days: days!) { (data, errorString) -> Void in
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if let errorString = errorString {
                    self.showAlert("notic", message: errorString)
                }
                
//                print("current weather is \(self.currentWeather)")
                
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
                        
                        print("how mangy forecats here and the num is \(lists?.count)")
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
    
    
    //MARK: - NSFetchedResultsController Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.None)
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.None)
        default:
            return
        }
    }
    
    //MARK: - Helper Methods
    
    func showAlert(title: String? , message: String?) {
        dispatch_async(dispatch_get_main_queue()){
            if title != nil && message != nil {
                let errorAlert =
                UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            }
        }
    }

    



}

