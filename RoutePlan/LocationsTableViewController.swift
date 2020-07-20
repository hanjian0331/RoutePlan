//
//  LocationsTableViewController.swift
//  RoutePlan
//
//  Created by hanjian on 2020/7/20.
//  Copyright © 2020 hanjian. All rights reserved.
//

import UIKit
import MapKit

class LocationsTableViewController: UITableViewController {
//    var handleMapSearchDelegate:HandleMapSearch? = nil
    var mapItems:[MKMapItem] = []
    weak var mapView: MKMapView?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

    }

    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mapItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let selectedItem = mapItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let mapView = mapView else {
            return
        }
        mapView.removeAnnotations(mapView.annotations)
        var annotations = [MKAnnotation]()
        for mapItem in mapItems {
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapItem.placemark.coordinate
            annotation.title = mapItem.placemark.title
            if let city = mapItem.placemark.locality, let state = mapItem.placemark.administrativeArea {
                annotation.subtitle = "\(city) \(state)"
            }
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
        
        let selectedMapItem = mapItems[indexPath.row]
        let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: selectedMapItem.placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        dismiss(animated: true, completion: nil)
    }
}

extension LocationsTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.mapItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
}
