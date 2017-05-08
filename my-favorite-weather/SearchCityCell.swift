//
//  SearchCityCell.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 31/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import UIKit

class SearchCityCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!

    func configureCell(_ city: City) {
        
        self.cityLabel.text = "\(city.name) - \(city.country)"
    }
    
}
