//
//  MapVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-07.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MapVC: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, HandleMapSearch {
    
    // MARK: - IBOutles
    @IBOutlet weak var mapView: MKMapView!
    
    var resultSearchController: UISearchController?
    
    // MARK: - Class variables
    let locationManager = CLLocationManager()
    let userLocation: CLLocation? = nil
    var selectedPin: MKPlacemark?
    
    var findFirstLocation = true
    
    
    // MARK: - Application runtime

    override func viewDidLoad() {
        super.viewDidLoad()
        findUserLocation()
        setupSearchController()
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dismissMapVCSegue" {
            guard let newTimeReportVC = segue.destination as? NewTimeReportTVC else { return }
            newTimeReportVC.workLocation = sender as? CLLocation
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        if let selectedPin = selectedPin, let location = selectedPin.location {
            performSegue(withIdentifier: "dismissMapVCSegue", sender: location)
        } else {
            performSegue(withIdentifier: "dismissMapVCSegue", sender: userLocation)
        }
    }
    
    @IBAction func dropLocationWithLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            let pin = MKPlacemark(coordinate: coordinate)
            selectedPin = pin
            annotation.coordinate = coordinate
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            
        }
    }
    
    
    // MARK: - Functions
    
    func findUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupSearchController() {
        guard let locationSearchTVC = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTVC") as? LocationSearchTVC else { return }
        resultSearchController = UISearchController(searchResultsController: locationSearchTVC)
        resultSearchController?.searchResultsUpdater = locationSearchTVC
        locationSearchTVC.mapView = mapView
        locationSearchTVC.delegate = self
        
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = NSLocalizedString("Search for places", comment: "Search for places")
        navigationItem.titleView = resultSearchController?.searchBar
        
        // Don't hide the search bar when searching
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        // Dims in the background while searching
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
    }
    
    // MARK: - CLLocationManager delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if findFirstLocation {
            if let location = locations.first {
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                mapView.addAnnotation(annotation)
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
            findFirstLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK: - Handle Map Search delegate
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    
}
