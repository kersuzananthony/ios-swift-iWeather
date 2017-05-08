//
//  CityService.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 21/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import Firebase
import FirebaseStorage

class DataService {
    
    static let instance = DataService()
    
    fileprivate let _context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    // MARK: - SearchCityController: When the user search for a specific city, we send a request to firebase to get a list of city beginning with the given param
    func getCitiesByFirebase(_ parameter: AnyObject?, completed: @escaping CityDownloadComplete) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var citiesToReturn: [City] = [City]()
        var numberCitiesToReturn: Int?
        
        if let info = parameter as? Dictionary<String, String>, let param = info["searchText"] {
        
            let ref: FIRDatabaseReference = FIRDatabase.database().reference().child("cities")
            
            ref.queryOrdered(byChild: "name")
                .queryStarting(atValue: param)
                .queryEnding(atValue: param + "\u{f8ff}")
                .queryLimited(toFirst: 20)
                .observeSingleEvent(of: .value, with: { (snap) in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    numberCitiesToReturn = Int(snap.childrenCount)
                    
                    for (index, item) in (snap.children.enumerated()) {
                        citiesToReturn.append(City(citySnapShot: item as! FIRDataSnapshot, paramInfo: info))
                        
                        if index + 1 == numberCitiesToReturn {
                            completed(citiesToReturn)
                        }
                    }
                })

        }
    }
    
    // MARK: - Return the weather of a given city
    func getWeatherForCity(city: City, needValidWeather: Bool, completed: @escaping WeatherDownloadComplete) throws {
        // Check if weather can be got from CoreData system
        let doesWeatherDataExist = self.doesWeatherDataExistAndIsItUseful(city: city)
        
        // MARK: - Case 1: weatherData has been retrieved from CoreData AND weatherData has not expired yet (display info in DetailViewController)
        // MARK: - Case 2: weatherData has been retrieved BUT data has already expired BUT we dont care about it (display info in HomeViewController)
        if (doesWeatherDataExist.exist && doesWeatherDataExist.isValid) || (doesWeatherDataExist.exist && !doesWeatherDataExist.isValid && !needValidWeather) {
            print("load weather data from CD")
            if let weatherData = doesWeatherDataExist.data?.weather {
                let weatherObject = NSKeyedUnarchiver.unarchiveObject(with: weatherData)
                if let weatherObjectToReturn = weatherObject as? Weather {
                    weatherObjectToReturn.lastUpdate = doesWeatherDataExist.data?.timestamp
                    completed(weatherObjectToReturn)
                } else {
                    throw WeatherError.cannotGetWeather(message: "Cannot get weather")
                }
            } else {
                throw WeatherError.cannotGetWeather(message: "Cannot get weather")
            }
        } else {
            print("load weather data from server")
            // MARK: - If weatherData exist but is not valid and we need to actualize it, so delete it from CoreData
            if let weatherData = doesWeatherDataExist.data {
                do {
                    try self.deleteWeatherData(weatherData: weatherData)
                } catch _ {
                    throw CoreDataError.cannotDeleteRow(message: "Cannot delete previous data")
                }
            }
            
            // MARK: - Case: WeatherData has not been retrieved from CoreData and we need to send a request to the server
            let url = getWeatherAPIURLForCityId(id: city.id)
            
            Alamofire.request(url,
                              method: .get,
                              parameters: nil,
                              encoding: URLEncoding.default,
                              headers: nil)
                .responseJSON { response -> Void in
                    if let dict = response.result.value as? Dictionary<String, AnyObject> {
                        let weather = Weather(weatherData: dict)
                        self.saveWeatherDataForCity(city: city, weather: weather)
                        completed(weather)
                    } else {
                        completed(nil)
                    }
            }
        }
    }
    
    // MARK: - Function called when the user use geolocation features to get weather info
    func getWeatherForLocation(lat: CGFloat, long: CGFloat, completed: @escaping WeatherDownloadCompleteWithLocation) {
        Alamofire.request(getWeatherAPIURLForCityLocation(long: long, lat: lat)).responseJSON { response in
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                print("we did it")
                if let cityInDict = dict["city"] as? Dictionary<String, AnyObject> {
                    let city = City(cityDict: cityInDict)
                    let weather = Weather(weatherData: dict)
                    completed(city, weather)
                } else {
                    completed(nil, nil)
                }
            }
        }
    }
    
    // MARK: - Check if the city has already been saved in CoreData previously
    // MARK: - If not we can save it
    func addCityToFavoriteCities(_ city: City) throws -> Bool {
        
        if !isCityAlreadyFavorite(id: city.id) {
            // Create newFavoriteCity
            let newFavoriteCity = NSEntityDescription.insertNewObject(forEntityName: Data.Entity.favoriteCities, into: self._context) as! FavoriteCities
            
            newFavoriteCity.name = city.name
            newFavoriteCity.country = city.country
            newFavoriteCity.id = NSNumber(value: city.id as Int)
            newFavoriteCity.latitude = city.coordinate.lat! as NSNumber
            newFavoriteCity.longitude = city.coordinate.long! as NSNumber
            
            do {
                try self._context.save()
                return true
            } catch _ {
                throw CoreDataError.cannotAddItem(message: "Cannot add the city")
            }

        } else {
            throw CoreDataError.cannotAddItem(message: "Cannot add the city")
        }
    }
    
    // MARK: Check if the given city is already stored in the FavoriteCities
    func isCityAlreadyFavorite(id: Int) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Data.Entity.favoriteCities)
        request.resultType = NSFetchRequestResultType.countResultType
        request.predicate = NSPredicate(format: "id = %d", id)
        
        do {
            let result = try self._context.fetch(request)
            
            if let r = result[0] as? Int, r > 0 {
                return true
            } else {
                return false
            }
            
        } catch _ {
            return false
        }
    }
    
    func getFavoriteCityById(id: Int) throws -> FavoriteCities {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Data.Entity.favoriteCities)
        request.predicate = NSPredicate(format: "id = %d", id)
        request.fetchLimit = 1
        
        do {
            let results = try self._context.fetch(request)
            
            if let results = results as? [NSManagedObject], results.count > 0, let favCity = results[0] as? FavoriteCities {
                return favCity
            } else {
                throw CoreDataError.dataDoNotExist(message: "Cannot get data")
            }
        } catch _ {
            throw CoreDataError.dataDoNotExist(message: "Cannot get data")
        }

    }
    
    // MARK: Delete the given city from the CoreData
    func deleteFavoriteCity(favoriteCity: FavoriteCities) throws  {
        if self.isCityAlreadyFavorite(id: Int(favoriteCity.id!)) {
            
            self._context.delete(favoriteCity)
            
            do {
                try self._context.save()
            } catch _ {
                throw CoreDataError.cannotDeleteRow(message: "Error while deleting data, please retry later!")
            }
        } else {
            throw CoreDataError.dataDoNotExist(message: "This favorite city does not exist!")
        }
    }
    
    // MARK: Delete a given city by its id
    func deleteFavoriteCityById(id: Int) throws {
        if self.isCityAlreadyFavorite(id: id) {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Data.Entity.favoriteCities)
            request.predicate = NSPredicate(format: "id = %d", id)
            
            do {
                let favoriteCities = try self._context.fetch(request) as! [FavoriteCities]
                
                self._context.delete(favoriteCities[0])
                
                try self._context.save()
            } catch _ {
                throw CoreDataError.dataDoNotExist(message: "This favorite city does not exist")
            }
        } else {
            throw CoreDataError.dataDoNotExist(message: "This favorite city does not exist!")
        }
    }
    
    // MARK: - Function called after getting weather info with a web request
    func saveWeatherDataForCity(city: City, weather: Weather) {
        print("Save new weather data")
        let cityId = city.id
        let weatherData = NSKeyedArchiver.archivedData(withRootObject: weather)
        
        let newWeatherData = NSEntityDescription.insertNewObject(forEntityName: Data.Entity.weatherData, into: self._context) as! WeatherData
        newWeatherData.city = cityId as! NSNumber
        newWeatherData.weather = weatherData
        newWeatherData.timestamp = Date()
        
        do {
            try self._context.save()
            
            if city.isFavorite == true  {
                Foundation.NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationCenter.updatedWeatherInfo), object: city, userInfo: nil)
            }
        } catch _ {
            CoreDataError.cannotAddItem(message: "Cannot save data")
        }
    }
    
    // MARK: - Function which check if weather of a given city is already stored in CoreData WeatherData Entity
    //       - If there is no data, return dont exist
    //       - If data is too old, return is not valid
    func doesWeatherDataExistAndIsItUseful(city: City) -> (exist: Bool, isValid: Bool, data: WeatherData?) {
        let weatherDataFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Data.Entity.weatherData)
        weatherDataFetchRequest.predicate = NSPredicate(format: "city = %d", city.id)
        weatherDataFetchRequest.fetchLimit = 1
        
        do {
            let results = try self._context.fetch(weatherDataFetchRequest)
            
            if let results = results as? [NSManagedObject], results.count > 0, let weatherData = results[0] as? WeatherData {
                
                if Date().timeIntervalSince(weatherData.timestamp! as Date) > TimeInterval(WEATHER_DATA_VALID_DURATION) {
                    // Data exists but is not valid
                    return (true, false, weatherData)
                } else {
                    // Data exists and is valid
                    return (true, true, weatherData)
                }
            } else {
                // Data does not exist
                return (false, false, nil)
            }
        } catch _ {
            // Error, data do not exist
            return (false, false, nil)
        }
    }
    
    // MARK: - Delete weatherData when it expires
    func deleteWeatherData(weatherData: WeatherData) throws {
        self._context.delete(weatherData)
        
        do {
            try self._context.save()
        } catch _ {
            throw CoreDataError.cannotDeleteRow(message: "Cannot delete previous data")
        }
    }
    
}
