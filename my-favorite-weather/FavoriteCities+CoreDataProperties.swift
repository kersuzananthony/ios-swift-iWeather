//
//  FavoriteCities+CoreDataProperties.swift
//  
//
//  Created by Kersuzan on 03/01/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FavoriteCities {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var country: String?
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var lastWeatherUpdate: NSDate?

}
