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
    
    fileprivate var _temperatureUnity: Temperature?
    fileprivate var _atmosphericPressureUnity: AtmosphericPressure?
    fileprivate var _windSpeedUnity: WindSpeed?
    
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
        if let configurationData = UserDefaults.standard.object(forKey: self.CONFIGURATION_KEY) as? Foundation.Data {
            if let configuration = NSKeyedUnarchiver.unarchiveObject(with: configurationData) as? Configuration {
                return configuration
            } else {
                return Configuration(temperature: Temperature.Celsius, wind: WindSpeed.KilometerPerHour, pressure: AtmosphericPressure.HectoPascal)
            }
        } else {
            return Configuration(temperature: Temperature.Celsius, wind: WindSpeed.KilometerPerHour, pressure: AtmosphericPressure.HectoPascal)
        }
    }
    
    func saveUserConfiguration() {
        let configurationData = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(configurationData, forKey: CONFIGURATION_KEY)
        UserDefaults.standard.synchronize()
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
        self._atmosphericPressureUnity = AtmosphericPressure(rawValue: aDecoder.decodeObject(forKey: "atmosphericPressureUnity") as! String)
        self._temperatureUnity = Temperature(rawValue: aDecoder.decodeObject(forKey: "temperatureUnity") as! String)
        self._windSpeedUnity = WindSpeed(rawValue: aDecoder.decodeObject(forKey: "windSpeedUnity") as! String)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self._temperatureUnity?.rawValue, forKey: "temperatureUnity")
        aCoder.encode(self._atmosphericPressureUnity?.rawValue, forKey: "atmosphericPressureUnity")
        aCoder.encode(self._windSpeedUnity?.rawValue, forKey: "windSpeedUnity")
    }
}
