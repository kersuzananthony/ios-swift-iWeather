//
//  WeatherInfoCellTableViewCell.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 30/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import UIKit

class WeatherInfoCell: UITableViewCell {

    @IBOutlet weak var dayTempLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Configure all the label with weatherDayInfo
    func configureCell(_ day: WeatherDay) {
        self.dayTempLabel.text = day.tempDay
        self.maxTempLabel.text = day.tempMax
        self.minTempLabel.text = day.tempMin
        self.datetimeLabel.text = day.day
        self.shortDescriptionLabel.text = day.shortDescription
        self.weatherImageView.image = UIImage(named: day.icon)
    }

}
