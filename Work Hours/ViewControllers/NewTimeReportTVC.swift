//
//  NewTimeReportTVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-07.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class NewTimeReportTVC: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    
    // MARK: - IBOutles
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var dateTxf: UITextField!
    @IBOutlet weak var titleTxf: UITextField!
    @IBOutlet weak var startTimeTxf: UITextField!
    @IBOutlet weak var endTimeTxf: UITextField!
    @IBOutlet weak var breakHourTxf: UITextField!
    @IBOutlet weak var breakMinutesTxf: UITextField!
    
    @IBOutlet weak var customerLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    @IBOutlet weak var breakHLbl: UILabel!
    @IBOutlet weak var breakMLbl: UILabel!
    
    @IBOutlet weak var abscentBtn: UISwitch!
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
    
    var date: Date?
    var startTime = Date()
    var endTime = Date()
    var breakTime: (Int, Int)?
    
    // MARK: - Application runtime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findUserLocation()
        
        // Creates a UIDatePicker for currentDate, startDate and endDate
        let (datePicker, dateToolbar) = setCurrentDatePicker()
        dateTxf.inputAccessoryView = dateToolbar
        dateTxf.inputView = datePicker
        
        let (startPicker, startToolbar) = setUpDatePicker(showStartTime: true)
        startTimeTxf.inputAccessoryView = startToolbar
        startTimeTxf.inputView = startPicker
        
        let (endPicker, endToolbar) = setUpDatePicker(showStartTime: false)
        endTimeTxf.inputAccessoryView = endToolbar
        endTimeTxf.inputView = endPicker
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalFileCollectionView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapSegue" {
            guard let mapVC = segue.destination as? MapVC else { return }
            if let location = workLocation {
                mapVC.userLocation = location
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        SpinnerManager.shared.startSpinner()
        
        var data: [String: Any?] = [:]
        guard let date = date,
            let hoursTxt = breakHourTxf.text,
            let minutesTxt = breakMinutesTxf.text,
            let customer = customerLbl.text
            else { return }
        
        // Hours and minutes to seconds
        var seconds = 0
        if let hours = Int(hoursTxt), let minutes = Int(minutesTxt) {
            seconds = (hours * 3600) + (minutes * 60 )
        }
        
        
        // Get location
        var location = CLLocation()
        if let workLocation = workLocation {
            location = workLocation
        } else if let workLocation =  userCurrentLocation {
            location = workLocation
        }
        
        // If abscentBtn is active
        if abscentBtn.isOn {
            data = [
                "date" : date,
                "abscent" : true,
                "uid" : Auth.auth().currentUser?.uid
            ]
        } else {
            data = [
                "date" : date,
                "title" : titleTxf.text,
                "startTime" : startTime,
                "endTime" : endTime,
                "breakTime" : seconds,
                "abscent" : false,
                "customer" : customer,
                "location" : GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                "notes" : notesTxv.text,
                "uid" : Auth.auth().currentUser?.uid
            ]
        }
        
        saveBtn.isEnabled = false
        cancelBtn.isEnabled = false
        
        FirebaseManager.shared.saveData(data: data) { (success) in
            if success {
                SpinnerManager.shared.stopSpinner()
                self.performSegue(withIdentifier: "unwindToStart", sender: nil)
            } else {
                SpinnerManager.shared.stopSpinner()
                print("You failed!")
                self.saveBtn.isEnabled = true
                self.cancelBtn.isEnabled = true
            }
        }
        
        // TODO: Save images
        // TODO: Send back to front page
    }
    
    
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
            titleTxf.isEnabled = false
            
            startTimeLbl.alpha = 0.3
            endTimeLbl.alpha = 0.3
            breakHLbl.alpha = 0.3
            breakMLbl.alpha = 0.3
            titleLbl.alpha = 0.3
            
            startTimeTxf.alpha = 0.3
            endTimeTxf.alpha = 0.3
            breakHourTxf.alpha = 0.3
            breakMinutesTxf.alpha = 0.3
            titleTxf.alpha = 0.3
        } else {
            startTimeTxf.isEnabled = true
            endTimeTxf.isEnabled = true
            breakHourTxf.isEnabled = true
            breakMinutesTxf.isEnabled = true
            titleTxf.isEnabled = true
            startTimeTxf.alpha = 1
            endTimeTxf.alpha = 1
            breakHourTxf.alpha = 1
            breakMinutesTxf.alpha = 1
            titleTxf.alpha = 1
            startTimeLbl.alpha = 1
            endTimeLbl.alpha = 1
            breakHLbl.alpha = 1
            breakMLbl.alpha = 1
            titleLbl.alpha = 1
        }
    }
    
    func setDataFromTimerVC() {
        dateTxf.text = dateFormatter.string(from: startTime)
        date = startTime
        dateFormatter.dateFormat = "HH:mm"
        startTimeTxf.text = dateFormatter.string(from: startTime)
        
        endTimeTxf.text = dateFormatter.string(from: endTime)
        
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
    
    func setCurrentDatePicker() -> (UIDatePicker, UIToolbar) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTxf.text = dateFormatter.string(from: Date())
        picker.date = Date()
        date = Date()
        picker.date = startTime
        date = startTime
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Custom navigatation bar buttons for the keyboard
        let doneBtn = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done keyboard"), style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneBtn], animated: false)
        toolbar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        toolbar.barTintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        picker.addTarget(self, action: #selector(handleUIDatePicker(sender:)), for: .valueChanged)
        return (picker, toolbar)
    }
    
    // New UIDatePicker for TextFields
    func setUpDatePicker(showStartTime: Bool) -> (UIDatePicker, UIToolbar) {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Custom navigatation bar buttons for the keyboard
        let doneBtn = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done (keyboard)"), style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([doneBtn], animated: false)
        toolbar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        toolbar.barTintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        if showStartTime {
            picker.date = startTime
            picker.tag = 1
            picker.addTarget(self, action: #selector(handleUIDatePicker(sender:)), for: .valueChanged)
        } else {
            picker.date = endTime
            picker.tag = 2
            picker.addTarget(self, action: #selector(handleUIDatePicker(sender:)), for: .valueChanged)
        }
        
        return (picker, toolbar)
    }
    
    // Checks if value has changed on uiDatePickers
    
    @objc func handleUIDatePicker(sender: UIDatePicker) {
        dateFormatter.dateFormat = "HH:mm"
        if sender.tag == 1 {
            startTimeTxf.text = dateFormatter.string(from: sender.date)
            date = sender.date
        } else if sender.tag == 2 {
            endTimeTxf.text = dateFormatter.string(from: sender.date)
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateTxf.text = dateFormatter.string(from: sender.date)
            date = sender.date
        }
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
    
    
    // MARK: - CollectionView Delegate, Datasource, FlowLayout
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return additionalFilesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "additionalFileCell", for: indexPath) as? AdditionalFileCell else { return UICollectionViewCell() }
        cell.imageView.image = additionalFilesArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
}
