//
//  Forecast.swift
//  WeatherReport
//
//  Created by zhangyunchen on 16/1/31.
//  Copyright © 2016年 zhangyunchen. All rights reserved.
//

import Foundation
import CoreData

class Forecast:NSManagedObject{
    @NSManaged var date:String
    // tempDescription descrip temp in min to max like " 13°C - 15°C"
    @NSManaged var tempDescription:String
    @NSManaged var weather:String
    @NSManaged var currentWeather:CurrentWeather
}