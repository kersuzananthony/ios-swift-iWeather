//
//  WeatherInfoView.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 01/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import UIKit

@IBDesignable class WeatherInfoView: UIView {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var dayTempLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var longDescriptionLabel: UILabel!
    @IBOutlet weak var dayTempLabel2: UILabel!
    @IBOutlet weak var nightTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!

    // MARK: - configure the view with info of the first weatherDay
    func configureView(city: City, weather: WeatherDay) {
        print("icon \(weather.icon)")
        self.cityNameLabel.text = city.name
        self.dayTempLabel.text = weather.tempDay
        self.weatherIconImageView.image = UIImage(named: weather.icon)
        self.longDescriptionLabel.text = weather.longDescription
        self.dayTempLabel2.text = weather.tempDay
        self.nightTempLabel.text = weather.tempNight
        self.maxTempLabel.text = weather.tempMax
        self.minTempLabel.text = weather.tempMin
        self.pressureLabel.text = weather.pressure
        self.windDirectionLabel.text = weather.windDirection
        self.windSpeedLabel.text = weather.windSpeed
        self.humidityLabel.text = weather.humidity
        
        self.isHidden = false
    }
    
    // Our custom view from the XIB file
    var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "WeatherInfoView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
}

