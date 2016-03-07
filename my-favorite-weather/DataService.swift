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

class DataService {
    
    static let instance = DataService()
    
    private let _context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - SearchCityController: When the user search for a specific city, we send a request to firebase to get a list of city beginning with the given param
    func getCitiesByFirebase(parameter: AnyObject?, completed: CityDownloadComplete) {
        var citiesToReturn: [City] = [City]()
        var numberCitiesToReturn: Int?
        let ref = Firebase(url:"https://i-weather.firebaseio.com/cities")
        
        if let info = parameter as? Dictionary<String, String>, param = info["searchText"] {
            print(param)
            ref.queryOrderedByChild("name")
                .queryStartingAtValue(param)
                .queryLimitedToNumberOfChildren(20)
                .observeSingleEventOfType(.Value, withBlock: { (snap) -> Void in
                    
                    numberCitiesToReturn = Int(snap.childrenCount)
                    
                    for (index, item) in snap.children.enumerate() {
                        citiesToReturn.append(City(citySnapShot: item as! FDataSnapshot, paramInfo: info))
                        
                        if index + 1 == numberCitiesToReturn {
                            completed(citiesToReturn)
                        }
                    }
                    } , withCancelBlock: nil)

        }
    }
    
    // MARK: - Return the weather of a given city
    func getWeatherForCity(city city: City, needValidWeather: Bool, completed: WeatherDownloadComplete) throws {
        // Check if weather can be got from CoreData system
        let doesWeatherDataExist = self.doesWeatherDataExistAndIsItUseful(city: city)
        
        // MARK: - Case 1: weatherData has been retrieved from CoreData AND weatherData has not expired yet (display info in DetailViewController)
        // MARK: - Case 2: weatherData has been retrieved BUT data has already expired BUT we dont care about it (display info in HomeViewController)
        if (doesWeatherDataExist.exist && doesWeatherDataExist.isValid) || (doesWeatherDataExist.exist && !doesWeatherDataExist.isValid && !needValidWeather) {
            print("load weather data from CD")
            if let weatherData = doesWeatherDataExist.data?.weather {
                let weatherObject = NSKeyedUnarchiver.unarchiveObjectWithData(weatherData)
                if let weatherObjectToReturn = weatherObject as? Weather {
                    weatherObjectToReturn.lastUpdate = doesWeatherDataExist.data?.timestamp
                    completed(weatherObjectToReturn)
                } else {
                    throw WeatherError.CannotGetWeather(message: "Cannot get weather")
                }
            } else {
                throw WeatherError.CannotGetWeather(message: "Cannot get weather")
            }
        } else {
            print("load weather data from server")
            // MARK: - If weatherData exist but is not valid and we need to actualize it, so delete it from CoreData
            if let weatherData = doesWeatherDataExist.data {
                do {
                    try self.deleteWeatherData(weatherData: weatherData)
                } catch _ {
                    throw CoreDataError.CannotDeleteRow(message: "Cannot delete previous data")
                }
            }
            
            // MARK: - Case: WeatherData has not been retrieved from CoreData and we need to send a request to the server
            if let id = city.id {
                Alamofire.request(Method.GET, getWeatherAPIURLForCityId(id: id),
                    parameters: nil,
                    encoding: ParameterEncoding.URLEncodedInURL,
                    headers: nil).responseJSON { response -> Void in
                        if let dict = response.result.value as? Dictionary<String, AnyObject> {
                            let weather = Weather(weatherData: dict)
                            self.saveWeatherDataForCity(city: city, weather: weather)
                            completed(weather)
                        } else {
                            completed(nil)
                        }
                    }
            } else {
                throw WeatherError.CannotGetWeather(message: "Cannot get weather")
            }
        }
    }
    
    // MARK: - Function called when the user use geolocation features to get weather info
    func getWeatherForLocation(lat lat: CGFloat, long: CGFloat, completed: WeatherDownloadCompleteWithLocation) {
        Alamofire.request(Method.GET, getWeatherAPIURLForCityLocation(long: long, lat: lat)).responseJSON { response in
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
    func addCityToFavoriteCities(city: City) throws -> Bool {
        
        if !isCityAlreadyFavorite(id: city.id) {
            // Create newFavoriteCity
            let newFavoriteCity = NSEntityDescription.insertNewObjectForEntityForName(Data.Entity.favoriteCities, inManagedObjectContext: self._context) as! FavoriteCities
            
            newFavoriteCity.name = city.name
            newFavoriteCity.country = city.country
            newFavoriteCity.id = NSNumber(integer: city.id)
            newFavoriteCity.latitude = city.coordinate.lat
            newFavoriteCity.longitude = city.coordinate.long
                    
            do {
                try self._context.save()
                return true
            } catch _ {
                throw CoreDataError.CannotAddItem(message: "Cannot add the city")
            }

        } else {
            throw CoreDataError.CannotAddItem(message: "Cannot add the city")
        }
    }
    
    // MARK: Check if the given city is already stored in the FavoriteCities
    func isCityAlreadyFavorite(id id: Int) -> Bool {
        let request = NSFetchRequest(entityName: Data.Entity.favoriteCities)
        request.resultType = NSFetchRequestResultType.CountResultType
        request.predicate = NSPredicate(format: "id = %d", id)
        
        do {
            let result = try self._context.executeFetchRequest(request)
            
            if let r = result[0] as? Int where r > 0 {
                return true
            } else {
                return false
            }
            
        } catch _ {
            return false
        }
    }
    
    func getFavoriteCityById(id id: Int) throws -> FavoriteCities {
        let request = NSFetchRequest(entityName: Data.Entity.favoriteCities)
        request.predicate = NSPredicate(format: "id = %d", id)
        request.fetchLimit = 1
        
        do {
            let results = try self._context.executeFetchRequest(request)
            
            if let results = results as? [NSManagedObject] where results.count > 0, let favCity = results[0] as? FavoriteCities {
                return favCity
            } else {
                throw CoreDataError.DataDoNotExist(message: "Cannot get data")
            }
        } catch _ {
            throw CoreDataError.DataDoNotExist(message: "Cannot get data")
        }

    }
    
    // MARK: Delete the given city from the CoreData
    func deleteFavoriteCity(favoriteCity favoriteCity: FavoriteCities) throws  {
        if self.isCityAlreadyFavorite(id: Int(favoriteCity.id!)) {
            
            self._context.deleteObject(favoriteCity)
            
            do {
                try self._context.save()
            } catch _ {
                throw CoreDataError.CannotDeleteRow(message: "Error while deleting data, please retry later!")
            }
        } else {
            throw CoreDataError.DataDoNotExist(message: "This favorite city does not exist!")
        }
    }
    
    // MARK: Delete a given city by its id
    func deleteFavoriteCityById(id id: Int) throws {
        if self.isCityAlreadyFavorite(id: id) {
            let request = NSFetchRequest(entityName: Data.Entity.favoriteCities)
            request.predicate = NSPredicate(format: "id = %d", id)
            
            do {
                let favoriteCities = try self._context.executeFetchRequest(request) as! [FavoriteCities]
                
                self._context.deleteObject(favoriteCities[0])
                
                try self._context.save()
            } catch _ {
                throw CoreDataError.DataDoNotExist(message: "This favorite city does not exist")
            }
        } else {
            throw CoreDataError.DataDoNotExist(message: "This favorite city does not exist!")
        }
    }
    
    // MARK: - Function called after getting weather info with a web request
    func saveWeatherDataForCity(city city: City, weather: Weather) {
        print("Save new weather data")
        let cityId = city.id
        let weatherData = NSKeyedArchiver.archivedDataWithRootObject(weather)
        
        let newWeatherData = NSEntityDescription.insertNewObjectForEntityForName(Data.Entity.weatherData, inManagedObjectContext: self._context) as! WeatherData
        newWeatherData.city = cityId
        newWeatherData.weather = weatherData
        newWeatherData.timestamp = NSDate()
        
        do {
            try self._context.save()
            
            if let isFavorite = city.isFavorite where isFavorite == true  {
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationCenter.updatedWeatherInfo, object: city, userInfo: nil)
            }
        } catch _ {
            CoreDataError.CannotAddItem(message: "Cannot save data")
        }
    }
    
    // MARK: - Function which check if weather of a given city is already stored in CoreData WeatherData Entity
    //       - If there is no data, return dont exist
    //       - If data is too old, return is not valid
    func doesWeatherDataExistAndIsItUseful(city city: City) -> (exist: Bool, isValid: Bool, data: WeatherData?) {
        let weatherDataFetchRequest = NSFetchRequest(entityName: Data.Entity.weatherData)
        weatherDataFetchRequest.predicate = NSPredicate(format: "city = %d", city.id)
        weatherDataFetchRequest.fetchLimit = 1
        
        do {
            let results = try self._context.executeFetchRequest(weatherDataFetchRequest)
            
            if let results = results as? [NSManagedObject] where results.count > 0, let weatherData = results[0] as? WeatherData {
                
                if NSDate().timeIntervalSinceDate(weatherData.timestamp!) > NSTimeInterval(WEATHER_DATA_VALID_DURATION) {
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
    func deleteWeatherData(weatherData weatherData: WeatherData) throws {
        self._context.deleteObject(weatherData)
        
        do {
            try self._context.save()
        } catch _ {
            throw CoreDataError.CannotDeleteRow(message: "Cannot delete previous data")
        }
    }
    
}