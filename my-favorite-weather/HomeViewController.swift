//
//  ViewController.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 21/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import iAd
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// MARK: - HomeViewController, @IBOutlet, @IBAction, Variables and main methods declaration
class HomeViewController: UIViewController, CLLocationManagerDelegate {

    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionView.reloadData()
    }
    
    // MARK: -IBOutlet
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // @MARK: - Controller variables
    let transition = PopAnimator()
    var selectedCell: UICollectionViewCell!
    var removeOptions: Bool = false
    var cancelRemoveGestureRecognize: UITapGestureRecognizer?
    var noFavoriteView: UIView?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var bannerView: ADBannerView?
    var loadBannerViewSuccess: Bool = false

    var locationManager: CLLocationManager = CLLocationManager()
    var appDel: AppDelegate = AppDelegate()
    var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    fileprivate var _fetchResultsController: NSFetchedResultsController<FavoriteCities>? = nil
    
    // MARK: - Change bar style
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: -IBAction
    @IBAction func locateMePressed(_ sender: UIButton) {
        
        if CLLocationManager.authorizationStatus() == .denied {
            let alertController = UIAlertController(title: NSLocalizedString("Settings", comment: "Settings"), message: NSLocalizedString("LOCATION_PERMISSION", comment: "Location permission message"), preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.cancel, handler: nil)
            let goToSettingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in
                
                if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(appSettings)
                }
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(goToSettingsAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            
            initIndicatorView()
            
            if let location = locationManager.location {
                let latitude = CGFloat(location.coordinate.latitude)
                let longitude = CGFloat(location.coordinate.longitude)
                
                DataService.instance.getWeatherForLocation(lat: latitude, long: longitude, completed: { (city: City?, weather: Weather?) -> () in
                    
                    self.stopIndicatorView()
                    
                    if let city = city, let weather = weather {
                        self.performSegue(withIdentifier: Storyboard.Segue.viewWeatherDetail, sender: ["city": city, "weather": weather])
                    } else {
                        self.displayCannotGetPositionMessage()
                    }
                })
            } else {
                stopIndicatorView()
                displayCannotGetPositionMessage()
                
            }
        }
    }
    
    func initIndicatorView() {
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopIndicatorView() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func displayCannotGetPositionMessage() {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("CANNOT GET WEATHER INFO", comment: "Cannot get weather info"), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the GPS
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        
        // MARK: - CollectionView Delegate and DataSource
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
     
        // MARK: - Core Data configuration
        appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.managedObjectContext
        
        // MARK: - NSNotificationCenter observers
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.removeCellOn(_:)), name: NSNotification.Name(rawValue: NotificationCenter.removeCityCellOn), object: nil)
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.removeCellOff(_:)), name: NSNotification.Name(rawValue: NotificationCenter.removeCityCellOff), object: nil)
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.problemWithData(_:)), name: NSNotification.Name(rawValue: NotificationCenter.errorManipulatingData), object: nil)
        Foundation.NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updatedWeatherInfo(_:)), name: NSNotification.Name(rawValue: NotificationCenter.updatedWeatherInfo), object: nil)
        
        // iAD
        //self.canDisplayBannerAds = true
    }
    
    func problemWithData(_ sender: Notification?) {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("INTERN ERROR", comment: "Core data intern error"), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadBannerViewSuccess = false
        displayNoFavoriteView()
        displayBannerAdvertising()
    }
    
    func updatedWeatherInfo(_ sender: Notification) {
        if let city = sender.object as? City {
            do {
                print("we must update it!!!")
                let favoriteCity = try DataService.instance.getFavoriteCityById(id: city.id)
                let indexPath = self.fetchResultsController.indexPath(forObject: favoriteCity)
                let cell = self.collectionView.cellForItem(at: indexPath!) as! CityCell
                cell.configureCell(favoriteCity)
            } catch _ {
                problemWithData(nil)
            }
        }
    }
    
    // MARK: - User has not added favorite cities yet. Display a UIView for informing him/her
    func displayNoFavoriteView() {
        if let number = self.fetchResultsController.sections?[0].numberOfObjects, number == 0 {
            if self.noFavoriteView == nil {
                self.noFavoriteView = NoFavoriteCityView()
                self.noFavoriteView!.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(self.noFavoriteView!)
                
                let horizontalConstraint = NSLayoutConstraint(item: self.noFavoriteView!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
                view.addConstraint(horizontalConstraint)
                
                let verticalConstraint = NSLayoutConstraint(item: self.noFavoriteView!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
                view.addConstraint(verticalConstraint)
                
                let widthConstraint = NSLayoutConstraint(item: self.noFavoriteView!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.size.width * 0.9)
                view.addConstraint(widthConstraint)
                
                let heightConstraint = NSLayoutConstraint(item: self.noFavoriteView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.noFavoriteView!.frame.size.height)
                view.addConstraint(heightConstraint)
            }
        } else {
            if let noFavoriteView = self.noFavoriteView {
                noFavoriteView.removeFromSuperview()
                self.noFavoriteView = nil
            }
        }
        
    }
    
    // MARK: - Function called by NSNotification when the user wants to delete a city from his / her favorite cities
    func removeCellOn(_ sender: AnyObject) {

        if self.removeOptions == false {
            cancelRemoveGestureRecognize = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.removeCellOff(_:)))
            self.view.addGestureRecognizer(cancelRemoveGestureRecognize!)
        }
        
        self.removeOptions = true
    }
    
    // MARK: - Function called by NSNotification when the user wants to stop deleting favorite cities
    func removeCellOff(_ sender: AnyObject) {
        
        for cell in self.collectionView.visibleCells as! [CityCell] {
            cell.removeTrashImageView()
        }
        
        self.view.removeGestureRecognizer(self.cancelRemoveGestureRecognize!)
        self.removeOptions = false
    }
    
    // MARK: - Prepare for Segue method
    // MARK: - Case 1: User wants to access weather detail by pressing one of his/her favorite cities
    // MARK: - Case 2: User wants to access weather detail by pressing geolocation button
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.Segue.viewWeatherDetail {
            if let destinationController = segue.destination as? DetailViewController, let favoriteCity = sender as? FavoriteCities {
                destinationController.transitioningDelegate = self
                destinationController.city = City(favoriteCity: favoriteCity)
            } else if let destinationController = segue.destination as? DetailViewController {
                if let aSender = sender as? Dictionary<String, AnyObject>, let city = aSender["city"] as? City, let weather = aSender["weather"] as? Weather {
                    destinationController.city = city
                    destinationController.weather = weather
                }
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 0.6 * self.view.frame.height
        let width: CGFloat = height / 1.36
        return CGSize(width: width, height: height)
    }
    
}


// MARK: - UICollectionViewDelegate methods
extension HomeViewController: UICollectionViewDelegate {
    
    // MARK: - didSelectItemAtIndexPath method
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.removeOptions {
            return
        }
        
        let selectedFavoriteCity = self.fetchResultsController.object(at: indexPath) as! FavoriteCities
        self.selectedCell = self.collectionView.cellForItem(at: indexPath)
        self.performSegue(withIdentifier: Storyboard.Segue.viewWeatherDetail, sender: selectedFavoriteCity)
    }

    // MARK: - canPerformAction method
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
}

// MARK: - UICollectionViewDataSource methods
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (self.fetchResultsController.sections?.count) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.fetchResultsController.sections?.count > 0 {
            let sectionInfo = self.fetchResultsController.sections![section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.cityCellIdentifier, for: indexPath) as! CityCell

        let city = self.fetchResultsController.object(at: indexPath) as! FavoriteCities
        
        cell.configureCell(city)
        
        return cell
    }
}

// MARK: - UIViewControllerTransitionDelegate methods
extension HomeViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController) ->
        UIViewControllerAnimatedTransitioning? {
            transition.originFrame = selectedCell!.superview!.convert(selectedCell!.frame, to: nil)
            
            transition.presenting = true
            return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}

// MARK: - NSFetchedResultsControllerDelegate methods
extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    var fetchResultsController: NSFetchedResultsController<FavoriteCities> {
        if self._fetchResultsController == nil {
            
            let fetchRequest = NSFetchRequest<FavoriteCities>()
            let entity = NSEntityDescription.entity(forEntityName: Data.Entity.favoriteCities, in: self.context)
            fetchRequest.entity = entity
            
            fetchRequest.fetchBatchSize = 20
            
            let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let aFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
            
            aFetchResultsController.delegate = self
            
            self._fetchResultsController = aFetchResultsController
            
            do {
                try _fetchResultsController!.performFetch()
                
                return self._fetchResultsController!
            } catch _ {
                abort()
            }
            
        } else {
            return self._fetchResultsController!
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        
        case .insert:
            print("Insert Event")
            self.collectionView.insertItems(at: [newIndexPath!])
            displayNoFavoriteView()
            
            
        case .delete:
            print("Delete Event")
            self.collectionView.deleteItems(at: [indexPath!])
            displayNoFavoriteView()
            
        default:
            return
        
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("content changed")
    }
    
}

extension HomeViewController: ADBannerViewDelegate {
    
    func displayBannerAdvertising() {
        prepareBannerView()
    }
    
    func prepareBannerView() {
        print(" --- Banner: Try Load ---")
        // Attempt to load a new banner ad:
        
        if self.bannerView == nil {
            self.bannerView = ADBannerView(frame: CGRect.zero)
            self.bannerView!.delegate = self
            let screenRect = UIScreen.main.bounds
            self.bannerView!.frame = CGRect(x: 0, y: screenRect.size.height - self.bannerView!.frame.height, width: screenRect.size.width, height: self.bannerView!.frame.size.height)
            self.bannerView!.layer.zPosition = 2
        }
    }
    
    func bannerFinished() {
        self.bannerView?.removeFromSuperview()
        self.bannerView = nil
    }
    
    func showBannerView() {
        self.view.addSubview(self.bannerView!)
    }
    
    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        print(" --- Banner: Load success --- ")
        self.loadBannerViewSuccess = true
        showBannerView()
    }
    
    func bannerViewWillLoadAd(_ banner: ADBannerView!) {
        print(" --- Banner: Unload --------")
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        print(" --- Banner: Action Failed --- ")
        
        if loadBannerViewSuccess == false {
            bannerFinished()
        }
    }
    
    func bannerViewActionDidFinish(_ banner: ADBannerView!) {
        print(" --- Banner: Action Finish --- ")
    }
    
    func bannerViewActionShouldBegin(_ banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
}
