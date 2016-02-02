//
//  Utils.swift
//  WeatherReport
//
//  Created by zhangyunchen on 16/1/28.
//  Copyright © 2016年 zhangyunchen. All rights reserved.
//

import Foundation

class Utils{

    static func getFahrenheit(temp:Double) -> Int{
        return Int(temp - 273.0)
    }
    
    static func getDate(date:Double) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        let date = NSDate(timeIntervalSince1970: date)
        return dateFormatter.stringFromDate(date)
    }
    
    
}