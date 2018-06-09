//
//  ViewController.swift
//  Decider
//
//  Created by Sam Warnick on 6/6/18.
//  Copyright © 2018 Sam Warnick. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSeachBar()
        setupMapView()
        
        if CLLocationManager.locationServicesEnabled() {
            findUserLocation();
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // testing build number
    }
    
    // MARK: - Private Functions
    
    private func setupSeachBar() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func setupMapView() {
        mapView.showsUserLocation = true
    }
    
    private func findUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            findUserLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinates = manager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
}
