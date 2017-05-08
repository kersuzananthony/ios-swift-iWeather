//
//  CityCell.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 30/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import UIKit

class CityCell: UICollectionViewCell {
    
    var city: FavoriteCities!
    var weatherDay: WeatherDay!
    let trashWidth: CGFloat = 30
    let trashHeight: CGFloat = 40
    var trashImageView: UIImageView?
    var deleteMode: Bool = false
    
    // MARK: -Outlet for CityCell
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(CityCell.deleteFavoriteCity(_:)))
        longPressGestureRecognizer.minimumPressDuration = 2.0
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func configureCell(_ city: FavoriteCities) {
        self.city = city
        self.cityNameLabel.text = city.name?.uppercased()
        
        City(favoriteCity: self.city).getWeather(needValidWeather: false, completed: { (weather: Weather?) -> () in
            if let weather = weather, let weatherDay = weather.getTodayWeather() {
                self.weatherDay = weatherDay
                self.weatherImageView.image = UIImage(named: "\(self.weatherDay.icon)_picture")!
                self.lastUpdateLabel.text = weather.lastUpdateString
            } else {
                self.lastUpdateLabel.text = NSLocalizedString("Cannot get last update info", comment: "Cannot get last update info")
                self.weatherImageView.image = UIImage(named: "landscape")
            }
        })
    }
    
    // MARK: - Function called by the longPressGestureRecognizer
    //         - Display the trash image in the top right corner of the cell
    func deleteFavoriteCity(_ sender: AnyObject) {
        
        if !deleteMode {
            trashImageView = UIImageView(frame: CGRect(x: self.bounds.width - trashWidth - 20, y: 20, width: trashWidth, height: trashHeight))
            
            trashImageView!.contentMode = UIViewContentMode.scaleAspectFit
            trashImageView!.isUserInteractionEnabled = true
            trashImageView!.image = UIImage(named: "trash")
            
            let confirmDeleteGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CityCell.deleteItem(_:)))
            trashImageView!.addGestureRecognizer(confirmDeleteGestureRecognizer)
            
            self.addSubview(trashImageView!)
            self.bringSubview(toFront: trashImageView!)
            
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.red.cgColor
            
            Foundation.NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationCenter.removeCityCellOn), object: nil))
            
            deleteMode = true
        }
        
    }
    
    func deleteItem(_ sender: AnyObject?) {
        do {
            try DataService.instance.deleteFavoriteCity(favoriteCity: city)
            Foundation.NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationCenter.removeCityCellOff), object: city))
            self.removeTrashImageView()
        } catch CoreDataError.cannotDeleteRow(message: let message) {
            Foundation.NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationCenter.errorManipulatingData), object: NSLocalizedString(message, comment: "Error message")))
        } catch CoreDataError.dataDoNotExist(message: let message) {
            Foundation.NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationCenter.errorManipulatingData), object: NSLocalizedString(message, comment: "Error message")))
        } catch _ {
            Foundation.NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationCenter.errorManipulatingData), object: NSLocalizedString("Error", comment: "Error message")))
        }
    }
    
    func removeTrashImageView() {
        if let trashImage = self.trashImageView {
            trashImage.removeFromSuperview()
            self.layer.borderWidth = 0
        }
        
        deleteMode = false
    }
}
