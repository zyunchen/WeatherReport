//
//  CurrentWeather.swift
//  WeatherReport
//
//  Created by zhangyunchen on 16/1/27.
//  Copyright © 2016年 zhangyunchen. All rights reserved.
//

import Foundation
import CoreData

class CurrentWeather:NSManagedObject {
    @NSManaged var cityName:String
    @NSManaged var countryName:String
    @NSManaged var temp:NSNumber
    @NSManaged var weather:String
    @NSManaged var forecasts:[Forecast]
}
