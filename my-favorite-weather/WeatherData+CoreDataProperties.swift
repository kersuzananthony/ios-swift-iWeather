//
//  WeatherData+CoreDataProperties.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 06/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WeatherData {

    @NSManaged var city: NSNumber?
    @NSManaged var weather: Foundation.Data?
    @NSManaged var timestamp: Date?

}
