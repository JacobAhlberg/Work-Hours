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

class NewTimeReportTVC: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    // MARK: - IBOutles
    
    @IBOutlet weak var dateTxf: UITextField!
    @IBOutlet weak var titleTxf: UITextField!
    @IBOutlet weak var startTimeTxf: UITextField!
    @IBOutlet weak var endTimeTxf: UITextField!
    @IBOutlet weak var breakHourTxf: UITextField!
    @IBOutlet weak var breakMinutesTxf: UITextField!
    @IBOutlet weak var abscentBtn: UISwitch!
    @IBOutlet weak var customerLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var notesTxv: UITextView!
    @IBOutlet weak var additionalFileCollectionView: UICollectionView!
    
    // MARK: - Class variables
    
    var locationManager = CLLocationManager()
    var newTimeReport = true
    var additionalFilesArray: [UIImage] = []
    
    let dateFormatter = DateFormatter()
    
    var startTime: Date?
    var endTime: Date?
    var breakTime: (Int, Int)?
    
    
    // MARK: - Application runtime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findUserLocation()
        
        // Creates a UIDatePicker for startDate and endDate
        let (startPicker, startToolbar) = setUpDatePicker(showStartTime: true)
        startTimeTxf.inputAccessoryView = startToolbar
        startTimeTxf.inputView = startPicker
        
        let (endPicker, endToolbar) = setUpDatePicker(showStartTime: false)
        endTimeTxf.inputAccessoryView = endToolbar
        endTimeTxf.inputView = endPicker
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalFileCollectionView.reloadData()
        currentDate()
        
        
        if let start = startTime {
            dateTxf.text = dateFormatter.string(from: start)
            dateFormatter.dateFormat = "HH:mm"
            startTimeTxf.text = dateFormatter.string(from: start)
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        
        if let end = endTime {
            endTimeTxf.text = dateFormatter.string(from: end)
        }
        
        if let brake = breakTime {
            breakHourTxf.text = String(brake.0)
            breakMinutesTxf.text = String(brake.1)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func startTimeTxfPressed(_ sender: UITextField) {
        
    }
    
    @IBAction func endTimeTxfPressed(_ sender: UITextField) {
        
    }
    
    @IBAction func tappedMap(_ sender: Any) {
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    
    @IBAction func cameraBtnWasPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func libraryBtnWasPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Functions
    
    func currentDate() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTxf.text = dateFormatter.string(from: Date())
        
    }
    
    func findUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // New UIDatePicker for TextFields
    func setUpDatePicker(showStartTime: Bool) -> (UIDatePicker, UIToolbar) {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Custom navigatation bar buttons for the keyboard
        let doneBtn = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done keyboard"), style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([doneBtn], animated: false)
        toolbar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        toolbar.barTintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        if showStartTime {
            if let start = startTime { picker.date = start }
            picker.tag = 1
            picker.addTarget(self, action: #selector(handleUIDatePicker(sender:)), for: .valueChanged)
        } else {
            if let end = endTime { picker.date = end }
            picker.tag = 2
            picker.addTarget(self, action: #selector(handleUIDatePicker(sender:)), for: .valueChanged)
        }
        
        return (picker, toolbar)
    }
    
    // Checks if value has changed on
    @objc func handleUIDatePicker(sender: UIDatePicker) {
        dateFormatter.dateFormat = "HH:mm"
        if sender.tag == 1 { startTimeTxf.text = dateFormatter.string(from: sender.date) }
        else { endTimeTxf.text = dateFormatter.string(from: sender.date) }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    
    // MARK: - ImagePickerController delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.additionalFilesArray.append(image)
        }
        dismiss(animated: true) {
            self.additionalFileCollectionView.reloadData()
        }
    }
    
    
    // MARK: - CollectionView Delegate & Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return additionalFilesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "additionalFileCell", for: indexPath) as? AdditionalFileCell else { return UICollectionViewCell() }
        cell.imageView.image = additionalFilesArray[indexPath.row]
        return cell
    }
    
}
