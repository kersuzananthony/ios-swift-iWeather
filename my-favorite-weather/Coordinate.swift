//
//  Coordinate.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 30/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import Foundation
import UIKit

struct Coordinate {
    
    let long: CGFloat!
    let lat: CGFloat!
    
    init(long: CGFloat, lat: CGFloat) {
        self.long = long
        self.lat = lat
    }
    
}