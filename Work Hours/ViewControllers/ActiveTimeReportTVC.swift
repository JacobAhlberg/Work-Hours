//
//  ActiveTimeReportTVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit
import Firebase

class ActiveTimeReportTVC: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    // MARK: - IBOutlets
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var abscentLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var startLbl: UILabel!
    @IBOutlet weak var endLbl: UILabel!
    @IBOutlet weak var breakLbl: UILabel!
    @IBOutlet weak var customerLbl: UILabel!
    
    @IBOutlet weak var noteView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Class Variables
    
    var activeReport: TimeReport?
    let dateFormatter = DateFormatter()
    
    var imagesNames: [String] = []
    
    // MARK: - Application runtime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let a = activeReport {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = a.date {
                dateLbl.text = dateFormatter.string(from: date)
            }
            if let abscent = a.abscent {
                abscentLbl.text = NSLocalizedString(String(abscent), comment: String(abscent))
            }
            if let title = a.title {
                titleLbl.text = title
            }
            dateFormatter.dateFormat = "HH:mm"
            if let start = a.startTime {
                startLbl.text = dateFormatter.string(from: start)
            }
            if let end = a.endTime {
                endLbl.text = dateFormatter.string(from: end)
            }
            if let breakText = a.breakTime {
                breakLbl.text = String(breakText)
            }
            if let customer = a.customer {
                customerLbl.text = customer
            }
            if let notes = a.notes {
                noteView.text = notes
            }
            if let images = a.images {
                imagesNames = images
            }
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activeImage", for: indexPath) as? ActiveTimeReportImageCell else { return UICollectionViewCell() }
        
        let storageRef = Storage.storage().reference()
        let imageloadRef = storageRef.child(imagesNames[indexPath.row])
        imageloadRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let data = data {
                    cell.imageView.image = UIImage(data: data)
                    collectionView.reloadData()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesNames.count
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
