//
//  ActiveTimeReportTVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit

class ActiveTimeReportTVC: UITableViewController {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var abscentLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var startLbl: UILabel!
    @IBOutlet weak var endLbl: UILabel!
    @IBOutlet weak var breakLbl: UILabel!
    @IBOutlet weak var customerLbl: UILabel!
    
    @IBOutlet weak var noteView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
