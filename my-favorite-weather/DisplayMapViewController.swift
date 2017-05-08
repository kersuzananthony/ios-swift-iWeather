//
//  DisplayMapViewController.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 30/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import UIKit
import MapKit

class DisplayMapViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - IBAction
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Change type of map
    @IBAction func typeMapPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.map.mapType = MKMapType.standard
        } else if sender.selectedSegmentIndex == 1 {
            self.map.mapType = MKMapType.satellite
        } else if sender.selectedSegmentIndex == 2 {
            self.map.mapType = MKMapType.hybrid
        }
    }
    
    // MARK: - Controller variables
    var city: City!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.delegate = self
        drawMap()
    }
    
    // MARK: - Center the map on the City coordinates and put an annotation
    func drawMap() {
        
        // Do any additional setup after loading the view.
        let latDelta: CLLocationDegrees = 4
            
        let longDelta: CLLocationDegrees = 4
            
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
            
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.city.coordinate.lat), longitude: CLLocationDegrees(self.city.coordinate.long))
            
        let location: CLLocationCoordinate2D = coordinate
            
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
        self.map.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        annotation.title = city.name
            
        self.map.addAnnotation(annotation)
    }
}

extension DisplayMapViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
    
}

