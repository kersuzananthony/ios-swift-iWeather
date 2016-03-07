//
//  Weather.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 21/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import Foundation
import UIKit

class Weather: NSObject, NSCoding {
    
    private var _weatherDays: [WeatherDay] = [WeatherDay]()
    
    private var _lastUpdate: NSDate?
    
    var weatherDays: [WeatherDay]? {
        return self._weatherDays
    }
    
    // MARK: - lastUpdate getter and setter
    var lastUpdate: NSDate? {
        get {
            return self._lastUpdate
        }
        set {
            self._lastUpdate = newValue
        }
    }
    
    // MARK: - Computed property which return the lastUpdate string
    var lastUpdateString: String! {
        if let lastUpdate = self._lastUpdate {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            return String.localizedStringWithFormat(NSLocalizedString("LAST_UPDATE %@", comment: "last weather update"), formatter.stringFromDate(lastUpdate))   
        } else {
            return ""
        }
    }
    
    // MARK: - Initialize class from a dictionary
    init(weatherData: Dictionary<String, AnyObject>) {

        if let weatherData = weatherData["list"] as? [Dictionary<String, AnyObject>] {
            for weatherDayData in weatherData {
                self._weatherDays.append(WeatherDay(weatherDayData: weatherDayData))
            }
            
        }
    }
    
    override init() {
        
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        self._weatherDays = aDecoder.decodeObjectForKey("weatherDays") as! [WeatherDay]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self._weatherDays, forKey: "weatherDays")
    }
    
    func getTodayWeather() -> WeatherDay? {
        let calendar = NSCalendar.currentCalendar()
        for weatherDay in self.weatherDays! {
            
            print(weatherDay.timestamp)
            
            if calendar.compareDate(NSDate(), toDate: weatherDay.timestamp, toUnitGranularity: NSCalendarUnit.Day) == NSComparisonResult.OrderedSame {
                return weatherDay
            }
        }
    
        return self.weatherDays![self.weatherDays!.count - 1]
    }
    
}
