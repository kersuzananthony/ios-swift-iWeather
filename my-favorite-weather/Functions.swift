//
//  Functions.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 08/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import Foundation
import UIKit

func randomInRange(_ range: Range<Int>) -> Int {
    let count = UInt32(range.upperBound - range.lowerBound)
    return  Int(arc4random_uniform(count)) + range.lowerBound
}

public func getWeatherAPIURLForCityId(id: Int) -> String {
    return "http://api.openweathermap.org/data/2.5/forecast/daily?id=\(id)&appid=\(openWeatherAPIKey)&cnt=7"
}

public func getWeatherAPIURLForCityLocation(long: CGFloat, lat: CGFloat) -> String {
    return "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(long)&appid=\(openWeatherAPIKey)&cnt=7"
}

public func blueColorAlpha(alpha: CGFloat) -> UIColor {
    return UIColor(red: 98 / 255, green: 181 / 255, blue: 255 / 255, alpha: alpha)
}
