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
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
