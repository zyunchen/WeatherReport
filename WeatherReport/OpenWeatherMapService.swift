//
//  OpenWeatherMapService.swift
//  WeatherReport
//
//  Created by zhangyunchen on 16/1/24.
//  Copyright © 2016年 zhangyunchen. All rights reserved.
//

import Foundation
import CoreLocation

typealias WeatherCompletionHandler = (AnyObject!, String?) -> Void

struct OpenWeatherMapService {
    private let appId = "b7e5bba475d3b8a7e2716fa52c4b2cde"
    private let baseURL = "http://api.openweathermap.org/data/2.5"
    var session = NSURLSession.sharedSession()
    
    struct Method {
        static let current = "/weather"
        static let forcast = "/forecast/daily"
    }
    
    func getWeatherInfoWithLocation(method:String,location:CLLocation,days:Int,completionHandler:WeatherCompletionHandler){
        
        guard let url = generateRequestURL(location, method:method,days:days) else{
            completionHandler(nil,"There is something wrong when get current weather")
            return
        }
        
        print("request url is \(url)")
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let error = error{
                print(error.localizedDescription)
            }
            if let data = data {
                self.parseResult(data,completionHanlder: completionHandler)
            }else{
                completionHandler(nil,"no data returned!")
            }
        }
        
        task.resume()
        
        
    }
    
    private func parseResult(data:NSData,completionHanlder:WeatherCompletionHandler){
        do{
            let parseData =
            try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            if let parseData = parseData {
                completionHanlder(parseData,nil)
            }else{
                completionHanlder(nil,"Unable to parse data")
            }
            
            
            
        }catch let error as NSError {
            print(error.localizedDescription)
            completionHanlder(nil,"Unable to parse data")
        }
    }
    
    private func generateRequestURL(location: CLLocation,method:String,days:Int) -> NSURL? {
        guard let components = NSURLComponents(string:baseURL + method) else {
            return nil
        }
        if method == Method.current {
            components.queryItems = [NSURLQueryItem(name:"lat", value:String(location.coordinate.latitude)),
                NSURLQueryItem(name:"lon", value:String(location.coordinate.longitude)),
                NSURLQueryItem(name:"appid", value:String(appId))]
        }
            else{
                components.queryItems = [NSURLQueryItem(name:"lat", value:String(location.coordinate.latitude)),
                    NSURLQueryItem(name:"lon", value:String(location.coordinate.longitude)),
                    NSURLQueryItem(name:"appid", value:String(appId)),
                    NSURLQueryItem(name:"cnt",value: String(days))]
            }
        
        return components.URL
    }
    
}
