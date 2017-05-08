//
//  DetailViewController.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 30/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    // MARK: - Controller Outlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Controller variables
    var city: City!
    var isFavorite: Bool = false
    var weather: Weather?
    var days: [WeatherDay]?
    var managedView: [UIView] = [UIView]()
    var tableHeaderView: UIView!
    var backgroundImageView: UIImageView!
    var favoriteImageView: UIImageView!
    var weatherInfo: WeatherInfoView!
    var topBar: UIView!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    // MARK: - Status bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        getScreenInfo()
        createTableViewHeader()
        createNavigationControls()
        isFavoriteCity()
        updateFavoriteImageView()
        displayWeatherInfo()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        getScreenInfo()
        createTableViewHeader()
        createNavigationControls()
        updateFavoriteImageView()
        displayWeatherInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isFavoriteCity()
        updateFavoriteImageView()
    }
    
    func getScreenInfo() {
        self.screenHeight = UIScreen.main.bounds.size.height
        self.screenWidth = UIScreen.main.bounds.size.width
    }
    
    func displayWeatherInfo() {
        if let weather = self.weather {
            // We got the weather because the user wants to get local weather
            if let days = weather.weatherDays, days.count > 0 {
                self.days = days
                print(days[0].icon)
                self.tableView.reloadData()
                self.backgroundImageView.image = UIImage(named: days[0].icon + "_picture")
                self.weatherInfo.configureView(city: self.city, weather: days[0])            }
        } else {
            // We did not get the weather because the user opened either a searched city or a favorite one
            city.getWeather(needValidWeather: true, completed: { (weather: Weather?) -> () in
                if let weather = weather, let days = weather.weatherDays, days.count > 0 {
                    self.days = days
                    self.tableView.reloadData()
                    self.backgroundImageView.image = UIImage(named: days[0].icon + "_picture")
                    self.weatherInfo.configureView(city: self.city, weather: days[0])
                    print(days[0].icon)
                } else {
                    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("CANNOT GET WEATHER INFO", comment: "Cannot get weather info"), preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (action) -> Void in
                        print("cancel pressed")
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }

    }
    
    // MARK: - Check if the opened city is in the user's favorite
    func isFavoriteCity() {
        if DataService.instance.isCityAlreadyFavorite(id: self.city.id) {
            self.isFavorite = true
        } else {
            self.isFavorite = false
        }
    }
    
    // MARK: - Update favorite image
    func updateFavoriteImageView() {
        let imageName = self.isFavorite ? "favorite-1" : "favorite-0"
        self.favoriteImageView.image = UIImage(named: imageName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.Segue.viewMap {
            if let destinationController = segue.destination as? DisplayMapViewController {
                destinationController.city = self.city
            }
        }
    }

    // MARK: - This function add a header to the top of the TableView
    func createTableViewHeader() {
        if self.tableHeaderView != nil {
            self.tableView.backgroundView = nil
        }
        
        // MARK: - Make UITableView background
        self.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight))
        self.backgroundImageView = UIImageView(frame: self.tableHeaderView.frame)
        self.backgroundImageView.backgroundColor = APP_BLUE_COLOR
        
        self.backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        self.tableHeaderView.addSubview(self.backgroundImageView)
        
        // MARK: - WeatherInfo initialization
//        self.weatherInfo = WeatherInfoView(frame: CGRect(x: CGRectGetMidX(self.view.frame) - self.screenWidth / 2, y: (self.screenHeight - 400) / 2, width: self.screenWidth, height: 400))
        self.weatherInfo = WeatherInfoView()
        let height: CGFloat = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ? 600 : 400
        self.weatherInfo.frame.size = CGSize(width: self.view.frame.width * 0.9, height: height)
        self.weatherInfo.frame.origin = CGPoint(x: self.view.frame.midX - self.weatherInfo.frame.size.width / 2, y: self.view.frame.midY - self.weatherInfo.frame.size.height / 2)
        
        
        self.weatherInfo.isHidden = true
        self.managedView.append(self.weatherInfo)
        self.tableHeaderView.addSubview(self.weatherInfo)
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.isOpaque = false
        self.tableView.backgroundView = self.tableHeaderView
        
        self.tableView.contentInset = UIEdgeInsets(top: self.screenHeight, left: 0, bottom: 0, right: 0)
        self.tableView.contentOffset = CGPoint(x: 0, y: -self.screenHeight)

    }
    
    // MARK: - This function add some navigation controls to the top of the screen
    func createNavigationControls() {
        if self.topBar != nil {
            self.topBar.removeFromSuperview()
        }
        
        // MARK: - Create a topBar
        self.topBar = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: 60))
        
        // MARK: - Add buttons to the TopBar
        let backImageView = UIImageView(frame: CGRect(x: 30, y: 25, width: 30, height: 30))
        backImageView.contentMode = UIViewContentMode.scaleAspectFit
        backImageView.image = UIImage(named: "back")
        backImageView.isUserInteractionEnabled = true
        
        let backImageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.goBackAction(_:)))
        backImageViewTapGestureRecognizer.numberOfTapsRequired = 1
        backImageView.addGestureRecognizer(backImageViewTapGestureRecognizer)
        self.topBar.addSubview(backImageView)
        
        // MARK: - Add map button
        let mapImageView = UIImageView(frame: CGRect(x: self.screenWidth - 60, y: 25, width: 30, height: 30))
        mapImageView.contentMode = UIViewContentMode.scaleAspectFit
        mapImageView.image = UIImage(named: "map-marker")
        mapImageView.isUserInteractionEnabled = true
        
        let mapImageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.mapButtonPressed(_:)))
        mapImageViewTapGestureRecognizer.numberOfTapsRequired = 1
        mapImageView.addGestureRecognizer(mapImageViewTapGestureRecognizer)
        self.topBar.addSubview(mapImageView)
        
        self.favoriteImageView = UIImageView(frame: CGRect(x: mapImageView.center.x - 60, y: 25, width: 30, height: 30))
        self.favoriteImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.favoriteImageView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.toggleFavorite(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.favoriteImageView.addGestureRecognizer(tapGestureRecognizer)
        self.topBar.addSubview(favoriteImageView)

        self.topBar.layer.zPosition = 2
        self.topBar.backgroundColor = blueColorAlpha(alpha: 0.0)
        self.view.addSubview(self.topBar)
    }
    
    func toggleFavorite(_ sender: AnyObject?) {
        if self.isFavorite {
            do {
                try DataService.instance.deleteFavoriteCityById(id: self.city.id)
                self.isFavorite = false
                self.updateFavoriteImageView()
            } catch _ {
                print("Error to handle")
            }
        } else {
            do {
                try DataService.instance.addCityToFavoriteCities(self.city)
                self.isFavorite = true
                self.updateFavoriteImageView()
            } catch _ {
                print("cannot add it")
            }
        }
    }
    
    func goBackAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func mapButtonPressed(_ sender: UIImageView!) {
        print("bonjour")
        self.performSegue(withIdentifier: Storyboard.Segue.viewMap, sender: self)
    }
    
}

extension DetailViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let positionTableViewOnScreen = -self.tableView.contentOffset.y
        updateTopBar(tablePosition: positionTableViewOnScreen)
        updateManagedView(tablePosition: positionTableViewOnScreen)
    }
    
    // MARK: - Calculate the color alpha of the topBar depending on the relative distance with the tableView
    func updateTopBar(tablePosition: CGFloat) {
        if let topBar = self.topBar {
            var alpha: Float
            if tablePosition > 100 {
                alpha = 0
            } else if (tablePosition >= 0 && tablePosition <= 100) {
                alpha = Float(100 - tablePosition) / 100
            } else {
                alpha = 1
            }
            
            topBar.backgroundColor = blueColorAlpha(alpha: CGFloat(alpha))
        }
    }
    
    func updateManagedView(tablePosition: CGFloat) {
        for mView in self.managedView {
            if tablePosition > mView.center.y + 50 {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    mView.layer.opacity = 1
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    mView.layer.opacity = 0
                })
            }
        }
    }
}

extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Storyboard.WeatherInfoCell, for: indexPath) as! WeatherInfoCell
        
        if let days = self.days {
            cell.configureCell(days[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.days?.count ?? 0
    }
}


