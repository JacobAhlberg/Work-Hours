//
//  NewTimeReportTVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-07.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit
import MapKit

class NewTimeReportTVC: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    
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
    var userCurrentLocation: CLLocation?
    var workLocation: CLLocation?
    
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
        setDataFromTimerVC()
        
        if let workLocation = workLocation {
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = workLocation.coordinate
            mapView.addAnnotation(annotation)
            let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) { }
    
    // MARK: - IBActions
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        // Warn with haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        let alertVC = UIAlertController(title: NSLocalizedString("Are you sure?", comment: "Are you sure?"), message: NSLocalizedString("Do you want to discard current report?", comment: "Do you want to discard current report?"), preferredStyle: .alert)
        let discardAction = UIAlertAction(title: NSLocalizedString("Discard", comment: "Discard"), style: .destructive) { (alert) in
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        alertVC.addAction(discardAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func abscentBtnPressed(_ sender: UISwitch) {
        if sender.isOn { userIsAbscent(userIsAbscent: true) }
        else { userIsAbscent(userIsAbscent: false) }
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
    
    func userIsAbscent(userIsAbscent abscent: Bool) {
        if abscent {
            startTimeTxf.isEnabled = false
            endTimeTxf.isEnabled = false
            breakHourTxf.isEnabled = false
            breakMinutesTxf.isEnabled = false
            startTimeTxf.alpha = 0.5
            endTimeTxf.alpha = 0.5
            breakHourTxf.alpha = 0.5
            breakMinutesTxf.alpha = 0.5
        } else {
            startTimeTxf.isEnabled = true
            endTimeTxf.isEnabled = true
            breakHourTxf.isEnabled = true
            breakMinutesTxf.isEnabled = true
            startTimeTxf.alpha = 1
            endTimeTxf.alpha = 1
            breakHourTxf.alpha = 1
            breakMinutesTxf.alpha = 1
        }
    }
    
    func currentDate() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTxf.text = dateFormatter.string(from: Date())
    }
    
    func setDataFromTimerVC() {
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
    
    func findUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.pausesLocationUpdatesAutomatically = true
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
    
    
    // MARK: - TextField delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismissing keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - CoreLocation delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if newTimeReport && workLocation == nil {
            let userLocation = locations[0] as CLLocation
            userCurrentLocation = userLocation
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 200, 200)
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation.coordinate
            mapView.addAnnotation(annotation)
            mapView.setRegion(region, animated: true)
            newTimeReport = false
        }
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
