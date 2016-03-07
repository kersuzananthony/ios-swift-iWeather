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

// MARK: - HomeViewController, @IBOutlet, @IBAction, Variables and main methods declaration
class HomeViewController: UIViewController, CLLocationManagerDelegate {

    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
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
    var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    private var _fetchResultsController: NSFetchedResultsController? = nil
    
    // MARK: - Change bar style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: -IBAction
    @IBAction func locateMePressed(sender: UIButton) {
        
        if CLLocationManager.authorizationStatus() == .Denied {
            let alertController = UIAlertController(title: NSLocalizedString("Settings", comment: "Settings"), message: NSLocalizedString("LOCATION_PERMISSION", comment: "Location permission message"), preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: UIAlertActionStyle.Cancel, handler: nil)
            let goToSettingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                
                if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(appSettings)
                }
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(goToSettingsAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            
            initIndicatorView()
            
            if let location = locationManager.location {
                let latitude = CGFloat(location.coordinate.latitude)
                let longitude = CGFloat(location.coordinate.longitude)
                
                DataService.instance.getWeatherForLocation(lat: latitude, long: longitude, completed: { (city: City?, weather: Weather?) -> () in
                    
                    self.stopIndicatorView()
                    
                    if let city = city, let weather = weather {
                        self.performSegueWithIdentifier(Storyboard.Segue.viewWeatherDetail, sender: ["city": city, "weather": weather])
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
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        self.activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopIndicatorView() {
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func displayCannotGetPositionMessage() {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("CANNOT GET WEATHER INFO", comment: "Cannot get weather info"), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        context = appDel.managedObjectContext
        
        // MARK: - NSNotificationCenter observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeCellOn:", name: NotificationCenter.removeCityCellOn, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeCellOff:", name: NotificationCenter.removeCityCellOff, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "problemWithData:", name: NotificationCenter.errorManipulatingData, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedWeatherInfo:", name: NotificationCenter.updatedWeatherInfo, object: nil)
        
        // iAD
        //self.canDisplayBannerAds = true
    }
    
    func problemWithData(sender: NSNotification?) {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("INTERN ERROR", comment: "Core data intern error"), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadBannerViewSuccess = false
        displayNoFavoriteView()
        displayBannerAdvertising()
    }
    
    func updatedWeatherInfo(sender: NSNotification) {
        if let city = sender.object as? City {
            do {
                print("we must update it!!!")
                let favoriteCity = try DataService.instance.getFavoriteCityById(id: city.id)
                let indexPath = self.fetchResultsController.indexPathForObject(favoriteCity)
                let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! CityCell
                cell.configureCell(favoriteCity)
            } catch _ {
                problemWithData(nil)
            }
        }
    }
    
    // MARK: - User has not added favorite cities yet. Display a UIView for informing him/her
    func displayNoFavoriteView() {
        print("number of object \(self.fetchResultsController.sections?[0].numberOfObjects)")
        if let number = self.fetchResultsController.sections?[0].numberOfObjects where number == 0 {
            if self.noFavoriteView == nil {
                self.noFavoriteView = NoFavoriteCityView()
                self.noFavoriteView!.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(self.noFavoriteView!)
                
                let horizontalConstraint = NSLayoutConstraint(item: self.noFavoriteView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                view.addConstraint(horizontalConstraint)
                
                let verticalConstraint = NSLayoutConstraint(item: self.noFavoriteView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                view.addConstraint(verticalConstraint)
                
                let widthConstraint = NSLayoutConstraint(item: self.noFavoriteView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: self.view.frame.size.width * 0.9)
                view.addConstraint(widthConstraint)
                
                let heightConstraint = NSLayoutConstraint(item: self.noFavoriteView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: self.noFavoriteView!.frame.size.height)
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
    func removeCellOn(sender: AnyObject) {

        if self.removeOptions == false {
            cancelRemoveGestureRecognize = UITapGestureRecognizer(target: self, action: "removeCellOff:")
            self.view.addGestureRecognizer(cancelRemoveGestureRecognize!)
        }
        
        self.removeOptions = true
    }
    
    // MARK: - Function called by NSNotification when the user wants to stop deleting favorite cities
    func removeCellOff(sender: AnyObject) {
        
        for cell in self.collectionView.visibleCells() as! [CityCell] {
            cell.removeTrashImageView()
        }
        
        self.view.removeGestureRecognizer(self.cancelRemoveGestureRecognize!)
        self.removeOptions = false
    }
    
    // MARK: - Prepare for Segue method
    // MARK: - Case 1: User wants to access weather detail by pressing one of his/her favorite cities
    // MARK: - Case 2: User wants to access weather detail by pressing geolocation button
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.Segue.viewWeatherDetail {
            if let destinationController = segue.destinationViewController as? DetailViewController, let favoriteCity = sender as? FavoriteCities {
                destinationController.transitioningDelegate = self
                destinationController.city = City(favoriteCity: favoriteCity)
            } else if let destinationController = segue.destinationViewController as? DetailViewController, let city = sender?["city"] as? City, let weather = sender?["weather"] as? Weather {
                destinationController.city = city
                destinationController.weather = weather
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height: CGFloat = 0.6 * self.view.frame.height
        let width: CGFloat = height / 1.36
        return CGSizeMake(width, height)
    }
    
}


// MARK: - UICollectionViewDelegate methods
extension HomeViewController: UICollectionViewDelegate {
    
    // MARK: - didSelectItemAtIndexPath method
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if self.removeOptions {
            return
        }
        
        let selectedFavoriteCity = self.fetchResultsController.objectAtIndexPath(indexPath) as! FavoriteCities
        self.selectedCell = self.collectionView.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier(Storyboard.Segue.viewWeatherDetail, sender: selectedFavoriteCity)
    }

    // MARK: - canPerformAction method
    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return true
    }
    
}

// MARK: - UICollectionViewDataSource methods
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return (self.fetchResultsController.sections?.count) ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.fetchResultsController.sections?.count > 0 {
            let sectionInfo = self.fetchResultsController.sections![section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.cityCellIdentifier, forIndexPath: indexPath) as! CityCell

        let city = self.fetchResultsController.objectAtIndexPath(indexPath) as! FavoriteCities
        
        cell.configureCell(city)
        
        return cell
    }
}

// MARK: - UIViewControllerTransitionDelegate methods
extension HomeViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(
        presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) ->
        UIViewControllerAnimatedTransitioning? {
            transition.originFrame = selectedCell!.superview!.convertRect(selectedCell!.frame, toView: nil)
            
            transition.presenting = true
            return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}

// MARK: - NSFetchedResultsControllerDelegate methods
extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    var fetchResultsController: NSFetchedResultsController {
        if self._fetchResultsController == nil {
            
            let fetchRequest = NSFetchRequest()
            let entity = NSEntityDescription.entityForName(Data.Entity.favoriteCities, inManagedObjectContext: self.context)
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
    
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        
        case .Insert:
            print("Insert Event")
            self.collectionView.insertItemsAtIndexPaths([newIndexPath!])
            displayNoFavoriteView()
            
            
        case .Delete:
            print("Delete Event")
            self.collectionView.deleteItemsAtIndexPaths([indexPath!])
            displayNoFavoriteView()
            
        default:
            return
        
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
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
            self.bannerView = ADBannerView(frame: CGRectZero)
            self.bannerView!.delegate = self
            let screenRect = UIScreen.mainScreen().bounds
            self.bannerView!.frame = CGRectMake(0, screenRect.size.height - self.bannerView!.frame.height, screenRect.size.width, self.bannerView!.frame.size.height)
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
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        print(" --- Banner: Load success --- ")
        self.loadBannerViewSuccess = true
        showBannerView()
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        print(" --- Banner: Unload --------")
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        print(" --- Banner: Action Failed --- ")
        
        if loadBannerViewSuccess == false {
            bannerFinished()
        }
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        print(" --- Banner: Action Finish --- ")
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
}
