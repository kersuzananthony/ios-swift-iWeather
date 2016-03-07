//
//  WeatherDay.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 01/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import Foundation

class WeatherDay: NSObject, NSCoding  {
    
    private let configuration = Configuration.instance.getUserConfiguration()
    
    override init() {
        
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        self._shortDescription = aDecoder.decodeObjectForKey("shortDescription") as? String
        self._longDescription = aDecoder.decodeObjectForKey("longDescription") as? String
        self._icon = aDecoder.decodeObjectForKey("icon") as? String
        self._day = aDecoder.decodeObjectForKey("day") as? String
        self._date = aDecoder.decodeObjectForKey("date") as? String
        self._time = aDecoder.decodeObjectForKey("time") as? String
        self._timestamp = aDecoder.decodeObjectForKey("timestamp") as? NSDate
        self._tempDay = aDecoder.decodeObjectForKey("tempDay") as? Double
        self._tempMax = aDecoder.decodeObjectForKey("tempMax") as? Double
        self._tempNight = aDecoder.decodeObjectForKey("tempNight") as? Double
        self._tempMin = aDecoder.decodeObjectForKey("tempMin") as? Double
        self._humidity = aDecoder.decodeObjectForKey("humidity") as? Double
        self._pressure = aDecoder.decodeObjectForKey("pressure") as? Double
        self._windSpeed = aDecoder.decodeObjectForKey("windSpeed") as? Double
        self._windDirection = aDecoder.decodeObjectForKey("windDirection") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self._shortDescription, forKey: "shortDescription")
        aCoder.encodeObject(self._longDescription, forKey: "longDescription")
        aCoder.encodeObject(self._icon, forKey: "icon")
        aCoder.encodeObject(self._day, forKey: "day")
        aCoder.encodeObject(self._date, forKey: "date")
        aCoder.encodeObject(self._time, forKey: "time")
        aCoder.encodeObject(self._timestamp, forKey: "timestamp")
        aCoder.encodeObject(self._tempDay, forKey: "tempDay")
        aCoder.encodeObject(self._tempNight, forKey: "tempNight")
        aCoder.encodeObject(self._tempMax, forKey: "tempMax")
        aCoder.encodeObject(self._tempMin, forKey: "tempMin")
        aCoder.encodeObject(self._humidity, forKey: "humidity")
        aCoder.encodeObject(self._pressure, forKey: "pressure")
        aCoder.encodeObject(self._windSpeed, forKey: "windSpeed")
        aCoder.encodeObject(self._windDirection, forKey: "windDirection")
    }
    
    
    // MARK: - Private properties
    private var _shortDescription: String?
    private var _longDescription: String?
    private var _icon: String?
    private var _day: String!
    private var _date: String!
    private var _time: String!
    private var _tempDay: Double?
    private var _tempMax: Double?
    private var _tempMin: Double?
    private var _tempNight: Double?
    private var _humidity: Double?
    private var _pressure: Double?
    private var _windSpeed: Double?
    private var _windDirection: String?
    private var _timestamp: NSDate!

    enum WindDirection: String {
        case N = "North"
        case NNE = "North/North Est"
        case NE = "North Est"
        case ENE = "Est/North Est"
        case E = "Est"
        case ESE = "Est/South Est"
        case SE = "South Est"
        case SSE = "South/South Est"
        case S = "South"
        case SSW = "South/South West"
        case SW = "South West"
        case WSW = "West/South West"
        case W =  "West"
        case WNW = "West/North West"
        case NW = "North West"
        case NNW = "North/North West"
    }
    
    var windSpeed: String {
        get {
            if let speed = self._windSpeed {
                var value: Double!
                
                if self.configuration.windSpeedUnity == WindSpeed.MeterPerSecond {
                    value = speed
                } else  if self.configuration.windSpeedUnity == WindSpeed.KilometerPerHour {
                    value = meterPerSecondToKilometerPerHour(speed)
                } else  if self.configuration.windSpeedUnity == WindSpeed.MilesPerHour {
                    value = meterPerSecondToMilesPerHour(speed)
                } else {
                    value = speed
                }
                
                return "\(Int(round(value))) \(self.configuration.windSpeedUnity.rawValue)"
            } else {
                return ""
            }
        }
    }
    
    var windDirection: String {
        get {
            if let windDirection = self._windDirection {
                return NSLocalizedString(windDirection, comment: "Wind direction")
            } else {
                return ""
            }
        }
    }
    
    var shortDescription: String {
        get {
            if let description = self._shortDescription {
                return NSLocalizedString(description.capitalizedString, comment: "weather short description")
            } else {
                return ""
            }
        }
    }
    
    var longDescription: String {
        get {
            if let description = self._longDescription {
                return NSLocalizedString(description.capitalizedString, comment: "weather long description")
            } else {
                return ""
            }
        }
    }
    
    var icon: String {
        get {
            if let icon = self._icon {
                return icon
            } else {
                return ""
            }
        }
    }
    
    var day: String {
        get {
            if _day == nil {
                return ""
            }
            return _day.uppercaseString
        }
    }
    
    var date: String {
        get {
            if _date == nil {
                return ""
            }
            return _date
        }
    }
    
    var time: String {
        get {
            if _time == nil {
                return ""
            }
            return _time
        }
    }
    
    var timestamp: NSDate! {
        get {
            return self._timestamp
        }
    }
    
    var tempDay: String {
        get {
            if let temp = self._tempDay {
                var value: Double!
                
                if self.configuration.temperatureUnity == Temperature.Kelvin {
                    value = temp
                } else if self.configuration.temperatureUnity == Temperature.Fahrenheit {
                    value = kelvinToFahrenheit(temp)
                } else if self.configuration.temperatureUnity == Temperature.Celsius {
                    value = kelvinToCelsius(temp)
                } else {
                    value = temp
                }
                
                return "\(Int(round(value))) \(NSLocalizedString(self.configuration.temperatureUnity.rawValue, comment: "Temperature unity"))"
            } else {
                return ""
            }
        }
    }
    
    var tempNight: String {
        get {
            if let temp = self._tempNight {
                var value: Double!
                
                if self.configuration.temperatureUnity == Temperature.Kelvin {
                    value = temp
                } else if self.configuration.temperatureUnity == Temperature.Fahrenheit {
                    value = kelvinToFahrenheit(temp)
                } else if self.configuration.temperatureUnity == Temperature.Celsius {
                    value = kelvinToCelsius(temp)
                } else {
                    value = temp
                }
                
                return "\(Int(round(value))) \(NSLocalizedString(self.configuration.temperatureUnity.rawValue, comment: "Temperature unity"))"
            } else {
                return ""
            }
        }
    }
    
    var tempMin: String {
        get {
            if let temp = self._tempMin {
                var value: Double!
                
                if self.configuration.temperatureUnity == Temperature.Kelvin {
                    value = temp
                } else if self.configuration.temperatureUnity == Temperature.Fahrenheit {
                    value = kelvinToFahrenheit(temp)
                } else if self.configuration.temperatureUnity == Temperature.Celsius {
                    value = kelvinToCelsius(temp)
                } else {
                    value = temp
                }
                
                return "\(Int(round(value))) \(NSLocalizedString(self.configuration.temperatureUnity.rawValue, comment: "Temperature unity"))"
            } else {
                return ""
            }
        }
    }
    
    var tempMax: String {
        get {
            if let temp = self._tempMax {
                var value: Double!
                
                if self.configuration.temperatureUnity == Temperature.Kelvin {
                    value = temp
                } else if self.configuration.temperatureUnity == Temperature.Fahrenheit {
                    value = kelvinToFahrenheit(temp)
                } else if self.configuration.temperatureUnity == Temperature.Celsius {
                    value = kelvinToCelsius(temp)
                } else {
                    value = temp
                }
                
                return "\(Int(round(value))) \(NSLocalizedString(self.configuration.temperatureUnity.rawValue, comment: "Temperature unity"))"
            } else {
                return ""
            }
        }
    }
    
    var humidity: String {
        get {
            if let humidity = self._humidity {
                return "\(Int(round(humidity)))%"
            } else {
                return ""
            }
        }
    }
    
    var pressure: String {
        get {
            if let pressure = self._pressure {
                var value: Double!
                
                if self.configuration.atmosphericPressureUnity == AtmosphericPressure.HectoPascal {
                    value = pressure
                } else if self.configuration.atmosphericPressureUnity == AtmosphericPressure.Torr {
                    value = hpatoTorr(pressure)
                } else {
                    value = pressure
                }
                
                return "\(Int(round(value))) \(self.configuration.atmosphericPressureUnity.rawValue)"
            } else {
                return ""
            }
        }
    }
    
    func kelvinToFahrenheit(kelvin: Double) -> Double {
        return (kelvin - 273.15) * 1.8 + 32.0
    }
    
    func kelvinToCelsius(kelvin: Double) -> Double {
        return kelvin - 273.15
    }
    
    func meterPerSecondToKilometerPerHour(speed: Double) -> Double {
        return speed * 3.6
    }
    
    func meterPerSecondToMilesPerHour(speed: Double) -> Double {
        return speed * 2.236936
    }
    
    func hpatoTorr(pressure: Double) -> Double {
        return pressure * 0.75006375541921
    }
    
    init(weatherDayData: Dictionary<String, AnyObject>) {
        
        //print(weatherDayData)
        
        // MARK: - datetime
        if let datetime = weatherDayData["dt"] as? Double {
            let date = NSDate(timeIntervalSince1970: datetime)
            self._timestamp = date
            let dayFormatter = NSDateFormatter()
            let dateFormatter = NSDateFormatter()
            let timeFormatter = NSDateFormatter()
            dayFormatter.dateFormat = "EE"
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            timeFormatter.dateFormat = "h:mm a"
            self._day = dayFormatter.stringFromDate(date)
            self._date = dateFormatter.stringFromDate(date)
            self._time = timeFormatter.stringFromDate(date)
        }
        
        // MARK: - weather sub dictionary
        if let weather = weatherDayData["weather"] as? [Dictionary<String, AnyObject>] {
            //print("main \(weather)")
            
            if let shortDescription = weather[0]["main"] as? String {
                self._shortDescription = shortDescription
            }
            
            if let longDescription = weather[0]["description"] as? String {
                self._longDescription = longDescription
            }
            
            if var icon = weather[0]["icon"] as? String {
                icon = icon.stringByReplacingOccurrencesOfString("dd", withString: "d")
                icon = icon.stringByReplacingOccurrencesOfString("nn", withString: "n")
                self._icon = icon
            }
        }
        
        // MARK: - Wind direction
        if let direc = weatherDayData["deg"] as? Double {
            switch (direc) {
            case 348.75...360:
                self._windDirection = WindDirection.N.rawValue
            case 0..<11.25:
                self._windDirection = WindDirection.N.rawValue
            case 11.25..<33.75:
                self._windDirection = WindDirection.NNE.rawValue
            case 33.75..<56.25:
                self._windDirection = WindDirection.NE.rawValue
            case 56.25..<78.75:
                self._windDirection = WindDirection.ENE.rawValue
            case 78.75..<101.25:
                self._windDirection = WindDirection.E.rawValue
            case 101.25..<123.75:
                self._windDirection = WindDirection.ESE.rawValue
            case 123.75..<146.25:
                self._windDirection = WindDirection.SE.rawValue
            case 146.25..<168.75:
                self._windDirection = WindDirection.SSE.rawValue
            case 168.75..<191.25:
                self._windDirection = WindDirection.S.rawValue
            case 191.25..<213.75:
                self._windDirection = WindDirection.SSW.rawValue
            case 213.75..<236.25:
                self._windDirection = WindDirection.SW.rawValue
            case 236.25..<258.75:
                self._windDirection = WindDirection.WSW.rawValue
            case 258.75..<281.25:
                self._windDirection = WindDirection.W.rawValue
            case 281.25..<303.75:
                self._windDirection = WindDirection.WNW.rawValue
            case 303.75..<326.25:
                self._windDirection = WindDirection.NW.rawValue
            case 326.25..<348.75:
                self._windDirection = WindDirection.NNW.rawValue
            default:
                self._windDirection = WindDirection.N.rawValue
            }
        }
        
        // MARK: - Wind speed
        if let windSpeed = weatherDayData["speed"] as? Double {
            self._windSpeed = windSpeed
        }

        // MARK: - Pressure
        if let pressure = weatherDayData["pressure"] as? Double {
            self._pressure = pressure
        }
        
        // MARK: - Humidity
        if let humidity = weatherDayData["humidity"] as? Double {
            self._humidity = humidity
        }
        
        // MARK: - Temperature
        if let temperatures = weatherDayData["temp"] as? Dictionary<String, AnyObject> {
            
            if let tempDay = temperatures["day"] as? Double {
                self._tempDay = tempDay
            }
            
            if let tempNight = temperatures["night"] as? Double {
                self._tempNight = tempNight
            }
            
            if let tempMin = temperatures["min"] as? Double {
                self._tempMin = tempMin
            }
            
            if let tempMax = temperatures["max"] as? Double {
                self._tempMax = tempMax
            }
            
        }
    }
    
}