//
//  Configuration.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 30/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import Foundation

class Configuration: NSObject, NSCoding {
    
    static let instance = Configuration()
    
    let CONFIGURATION_KEY = "UserConfiguration"
    
    private var _temperatureUnity: Temperature?
    private var _atmosphericPressureUnity: AtmosphericPressure?
    private var _windSpeedUnity: WindSpeed?
    
    var temperatureUnity: Temperature! {
        get {
            return self._temperatureUnity ?? Temperature.Celsius
        }
        set {
            self._temperatureUnity = newValue
        }
    }
    
    var atmosphericPressureUnity: AtmosphericPressure! {
        get {
            return self._atmosphericPressureUnity ?? AtmosphericPressure.HectoPascal
        }
        set {
            self._atmosphericPressureUnity = newValue
        }
    }
    
    var windSpeedUnity: WindSpeed! {
        get {
            return self._windSpeedUnity ?? WindSpeed.KilometerPerHour
        }
        set {
            self._windSpeedUnity = newValue
        }
    }
    
    func getUserConfiguration() -> Configuration {
        if let configurationData = NSUserDefaults.standardUserDefaults().objectForKey(self.CONFIGURATION_KEY) as? NSData {
            if let configuration = NSKeyedUnarchiver.unarchiveObjectWithData(configurationData) as? Configuration {
                return configuration
            } else {
                return Configuration(temperature: Temperature.Celsius, wind: WindSpeed.KilometerPerHour, pressure: AtmosphericPressure.HectoPascal)
            }
        } else {
            return Configuration(temperature: Temperature.Celsius, wind: WindSpeed.KilometerPerHour, pressure: AtmosphericPressure.HectoPascal)
        }
    }
    
    func saveUserConfiguration() {
        let configurationData = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(configurationData, forKey: CONFIGURATION_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    init(temperature: Temperature, wind: WindSpeed, pressure: AtmosphericPressure) {
        super.init()
        self._temperatureUnity = temperature
        self._windSpeedUnity = wind
        self._atmosphericPressureUnity = pressure
        saveUserConfiguration()
    }
    
    override init() {
        
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
        self._atmosphericPressureUnity = AtmosphericPressure(rawValue: aDecoder.decodeObjectForKey("atmosphericPressureUnity") as! String)
        self._temperatureUnity = Temperature(rawValue: aDecoder.decodeObjectForKey("temperatureUnity") as! String)
        self._windSpeedUnity = WindSpeed(rawValue: aDecoder.decodeObjectForKey("windSpeedUnity") as! String)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self._temperatureUnity?.rawValue, forKey: "temperatureUnity")
        aCoder.encodeObject(self._atmosphericPressureUnity?.rawValue, forKey: "atmosphericPressureUnity")
        aCoder.encodeObject(self._windSpeedUnity?.rawValue, forKey: "windSpeedUnity")
    }
}