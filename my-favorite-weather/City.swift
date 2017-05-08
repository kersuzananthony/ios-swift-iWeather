//
//  City.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 21/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class City {
    
    // MARK: - private variables
    fileprivate var _id: Int!
    fileprivate var _name: String!
    fileprivate var _country: String!
    fileprivate var _coordinate: Coordinate!
    fileprivate var _isFavorite: Bool!
    
    // MARK: - getter and setters
    var id: Int {
        return self._id
    }
    
    var name: String {
        return self._name
    }
    
    var country: String {
        return self._country
    }
    
    var coordinate: Coordinate {
        return self._coordinate
    }
    
    var isFavorite: Bool {
        return self._isFavorite
    }
    
    func getWeather(needValidWeather: Bool, completed: @escaping WeatherDownloadComplete) {
        do {
            try DataService.instance.getWeatherForCity(city: self, needValidWeather: needValidWeather) { (weather: Weather?) -> () in
                completed(weather)
            }
        } catch _ {
            completed(nil)
        }
    }
    
    // MARK: - initialize with a dictionnary (Get weather from locate me feature)
    init(cityDict: Dictionary<String, AnyObject>) {
        if let id = cityDict["_id"] as? Int ?? cityDict["id"] as? Int, let name = cityDict["name"] as? String, let country = cityDict["country"] as? String, let coord = cityDict["coord"] as? Dictionary<String, AnyObject> {
            if let lat = coord["lat"] as? Float, let long = coord["lon"] as? Float {
                self._coordinate = Coordinate(long: CGFloat(long), lat: CGFloat(lat))
                self._id = id
                self._name = name
                self._country = country
                self._isFavorite = false
            }
        }
    }
    
    // MARK: - initialize data with firebase snapshot result
    init(citySnapShot: FIRDataSnapshot, paramInfo: Dictionary<String, String>) {
        guard let value = citySnapShot.value as? Dictionary<String, AnyObject> else {
            return
        }
        
        if let id = value["_id"] as? Int, let name = value["name"] as? String, let country = value["country"] as? String, let coord = value["coord"] as? Dictionary<String, AnyObject> {
            if let lat = coord["lat"] as? Float, let long = coord["lon"] as? Float {
                self._coordinate = Coordinate(long: CGFloat(long), lat: CGFloat(lat))
                self._id = id
                self._country = country
                self._isFavorite = false
                
                if let cityLatinVersion = paramInfo["searchText"], cityLatinVersion == name, let localeVersion = paramInfo["localeVersion"], let language = paramInfo["language"] {
                
                    if language == Language.Chinese.rawValue && (self._country == Country.China.rawValue || self._country == Country.Hongkong.rawValue || self._country == Country.Taiwan.rawValue) {
                        self._name = "\(localeVersion) (\(name))"
                    } else if language == Language.Korean.rawValue && (self._country == Country.NorthKorea.rawValue || self._country == Country.SouthKorea.rawValue) {
                        self._name = "\(localeVersion) (\(name))"
                    } else if language == Language.Japanese.rawValue && self._country == Country.Japan.rawValue {
                        self._name = "\(localeVersion) (\(name))"
                    } else if language == Language.Thai.rawValue && self._country == Country.Thailand.rawValue {
                        self._name = "\(localeVersion) (\(name))"
                    } else if language == Language.Russian.rawValue && self._country == Country.Russia.rawValue {
                        self._name = "\(localeVersion) (\(name))"
                    } else if language == Language.Greek.rawValue && self._country == Country.Greece.rawValue {
                        self._name = "\(localeVersion) (\(name))"
                    } else  if language == Language.Arabic.rawValue && self._country == Country.SouthArabia.rawValue {
                        self._name = "\(localeVersion) (\(name))"
                    } else {
                        self._name = name
                    }
                } else {
                    self._name = name
                }
            }
        }
    }
    
    // MARK: - initialize data from a FavoriteCity item
    init(favoriteCity: FavoriteCities) {
        self._id = favoriteCity.id as! Int
        self._name = favoriteCity.name
        self._country = favoriteCity.country
        self._coordinate = Coordinate(long: CGFloat(favoriteCity.longitude!), lat: CGFloat(favoriteCity.latitude!))
        self._isFavorite = true
    }
}
