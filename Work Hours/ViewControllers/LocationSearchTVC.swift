//
//  LocationSearchTableView.swift
//  Work Hours
//
//  Created by Jacob Ahlberg on 2018-02-13.
//  Copyright © 2018 Jacob Ahlberg. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTVC: UITableViewController, UISearchResultsUpdating {

    // MARK: - Class variables
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    
    var delegate: HandleMapSearch?
    
    // MARK: - Application runtime
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "locationSearchCell") else { return UITableViewCell() }
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        delegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UISearchResult
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let error = error {
                print(error)
            }
            
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }


}
