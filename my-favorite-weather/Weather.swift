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
    
    fileprivate var _weatherDays: [WeatherDay] = [WeatherDay]()
    
    fileprivate var _lastUpdate: Date?
    
    var weatherDays: [WeatherDay]? {
        return self._weatherDays
    }
    
    // MARK: - lastUpdate getter and setter
    var lastUpdate: Date? {
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
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.short
            formatter.timeStyle = DateFormatter.Style.short
            return String.localizedStringWithFormat(NSLocalizedString("LAST_UPDATE %@", comment: "last weather update"), formatter.string(from: lastUpdate))   
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
        self._weatherDays = aDecoder.decodeObject(forKey: "weatherDays") as! [WeatherDay]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self._weatherDays, forKey: "weatherDays")
    }
    
    func getTodayWeather() -> WeatherDay? {
        let calendar = Calendar.current
        for weatherDay in self.weatherDays! {
            
            print(weatherDay.timestamp)
            
            if (calendar as NSCalendar).compare(Date(), to: weatherDay.timestamp as Date, toUnitGranularity: NSCalendar.Unit.day) == ComparisonResult.orderedSame {
                return weatherDay
            }
        }
    
        return self.weatherDays![self.weatherDays!.count - 1]
    }
    
}
