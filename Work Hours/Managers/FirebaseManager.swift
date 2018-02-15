//
//  FirebaseManager.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-15.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    static var instance = FirebaseManager()
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    func fetchTimeReports(handler: @escaping ([TimeReport]) -> ()) {
        
        var fetchedReports: [TimeReport] = []
        guard let uid = user?.uid else { return }
        let reportsRef = db.collection("timeReports")
        reportsRef.whereField("uid", isEqualTo: uid).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let report = TimeReport(data: document.data())
                    fetchedReports.append(report)
                }
            }
            handler(fetchedReports)
        }
    }
    
    func fetchCustomers(handler: @escaping (_ customers: [String]?) -> ()) {
        let customersRef = db.collection("customers")
        customersRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error)
                handler(nil)
            } else {
                var customers: [String] = []
                guard let snapshots = querySnapshot else { return }
                for customer in snapshots.documents {
                    let value = customer.data()
                    guard let name = value["name"] as? String else { continue }
                    customers.append(name)
                }
                handler(customers)
            }
        }
        
    }
    
    func saveData(data : [String: Any?], handler: @escaping (Bool) -> ()) {
        let timeReportRef = db.collection("timeReports")
        timeReportRef.addDocument(data: data) { error in
            if let error = error {
                print("Error adding document: \(error)")
                handler(false)
            } else {
                handler(true)
            }
        }
    }
}








