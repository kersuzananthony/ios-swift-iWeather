//
//  Constants.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 21/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import Foundation
import UIKit

public let APP_BLUE_COLOR = UIColor(red: 98 / 255, green: 181 / 255, blue: 255 / 255, alpha: 1)
public let WEATHER_DATA_VALID_DURATION = 3600 * 12
public let APP_ID = "1076216323"

typealias CityDownloadComplete = ([City]) -> ()
typealias WeatherDownloadComplete = (Weather?) -> ()
typealias WeatherDownloadCompleteWithLocation = (City?, Weather?) -> ()

enum Temperature: String {
    case Celsius, Fahrenheit, Kelvin
    
    static let getAll = [Celsius, Fahrenheit, Kelvin]
}

enum WindSpeed: String {
    case MeterPerSecond = "m/s"
    case KilometerPerHour = "km/h"
    case MilesPerHour = "mph"
    
    static let getAll = [MeterPerSecond, KilometerPerHour, MilesPerHour]
}

enum AtmosphericPressure: String {
    case HectoPascal = "hPa"
    case Torr = "Torr"
    
    static let getAll = [HectoPascal, Torr]
}

enum CoreDataError: ErrorType {
    case CannotDeleteRow(message: String)
    case DataDoNotExist(message: String)
    case CannotAddItem(message: String)
    case NoItemToAdd(message: String)
}

enum WeatherError: ErrorType {
    case CannotGetWeather(message: String)
}

enum EntityError: ErrorType {
    case EntityNotInstantiable(message: String)
}

enum Country: String {
    case China = "CN"
    case Hongkong = "HK"
    case Taiwan = "TW"
    case SouthKorea = "KR"
    case NorthKorea = "KP"
    case Japan = "JP"
    case Russia = "RU"
    case Greece = "GR"
    case Thailand = "TH"
    case SouthArabia = "SA"
}

enum Language: String {
    case Chinese = "zh"
    case Japanese = "ja"
    case Korean = "ko"
    case Russian = "ru"
    case Arabic = "ar"
    case Greek = "el"
    case Thai = "th"
}

struct Storyboard {
    static let cityCellIdentifier: String = "CityCell"
    static let WeatherInfoCell: String = "WeatherInfoCell"
    static let CityResultCell: String = "CityResultCell"
    
    struct Segue {
        static let viewWeatherDetail: String = "ViewWeatherDetail"
        static let viewMap: String = "ViewMap"
        static let viewConfiguration: String = "ViewConfiguration"
        static let viewWeatherDetailForCitySearched = "ViewWeatherDetailForCitySearched"
        static let viewWeatherDetailWithLocation = "ViewWeatherDetailWithLocation"
    }
}

struct Data {
    struct Entity {
        static let favoriteCities: String = "FavoriteCities"
        static let weatherData: String  = "WeatherData"
    }
}

struct NotificationCenter {
    static let removeCityCellOn: String = "removeCityCellOn"
    static let removeCityCellOff: String = "removeCityCellOff"
    static let updatedWeatherInfo: String = "updatedWeatherInfo"
    static let errorManipulatingData: String = "errorManipulatingData"
}

