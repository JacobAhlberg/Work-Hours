//
//  NewTimeReportTVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-07.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NewTimeReportTVC: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    // MARK: - IBOutles
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var appendicesImageView: UIImageView!
    
    // MARK: - Variables
    var locationManager = CLLocationManager()
    
    var newTimeReport = true
    
    
    // MARK: - Application runtime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findUserLocation()
        
        
    }
    
    // MARK: - IBActions
    
    @IBAction func tappedMap(_ sender: Any) {
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    @IBAction func cameraBtnWasPressed(_ sender: Any) {
    }
    
    @IBAction func libraryBtnWasPressed(_ sender: Any) {
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
    
    
    // MARK: - CoreLocation delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if newTimeReport {
            let userLocation = locations[0] as CLLocation
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 200, 200)
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation.coordinate
            mapView.addAnnotation(annotation)
            mapView.setRegion(region, animated: true)
            newTimeReport = false
        }
        
    }
    
    // MARK: - MapView delegates
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "currentLocation") as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "currentLocation")
        }
        
        annotationView?.pinTintColor = #colorLiteral(red: 0.3636682928, green: 0.6938934922, blue: 0.8256246448, alpha: 1)
        annotationView?.isEnabled = false
        return annotationView
    }
    
    
    
}
