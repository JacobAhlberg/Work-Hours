//
//  PopoverVC.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-09.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit

class PopoverVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func newTimeReportPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("NewTimeReport"), object: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func timerBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("NewTimerStart"), object: nil)
        self.dismiss(animated: false, completion: nil)
    }
    


}
