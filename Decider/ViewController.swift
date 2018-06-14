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
//    private var search = MKLocalSearch()
    private let completer = MKLocalSearchCompleter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSeachBar()
        setupMapView()
        
        completer.delegate = self
        completer.region = mapView.region
    }
    
    // MARK: - Private Functions
    
    private func setupSeachBar() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func setupMapView() {
        if CLLocationManager.locationServicesEnabled() {
            findUserLocation();
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.showsUserLocation = true
//        mapView.showsCompass = true
//        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
    }
    
    private func findUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
    }
    
    // MARK: - Actions
    @IBAction func goToTopResult() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = completer.results.first?.title
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        mapView.removeAnnotations(mapView.annotations)
        search.start() { response, _ in
            guard let response = response else { return }
            let annotations: [MKPointAnnotation] = response.mapItems.map { mapItem in
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                return annotation
            }
            self.mapView.addAnnotations(annotations)
            if let coordinates = annotations.first?.coordinate {
                let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        completer.queryFragment = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = completer.results.first?.title
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        mapView.removeAnnotations(mapView.annotations)
        var annotations = [MKPointAnnotation]()
        search.start() { response, _ in
            guard let response = response else { return }
            annotations.append(contentsOf: response.mapItems.map { mapItem in
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                return annotation
            })
        }
        
        mapView.addAnnotations(annotations)
        if let coordinates = annotations.first?.coordinate {
            let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
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
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
}

extension ViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        topResultButton.titleLabel?.text = completer.results.first?.title
    }
}
