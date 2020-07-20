//
//  ViewController.swift
//  RoutePlan
//
//  Created by hanjian on 2020/7/15.
//  Copyright © 2020 hanjian. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var resultSearchController:UISearchController? = nil
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let latitude = UserDefaults.standard.double(forKey: "latitude")
        let longitude = UserDefaults.standard.double(forKey: "longitude")
        if latitude != 0 && longitude != 0  {
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
            mapView.setRegion(region, animated: true)
        }
        
        let locationsTableViewController = LocationsTableViewController()
        locationsTableViewController.mapView = mapView
        resultSearchController = UISearchController(searchResultsController: locationsTableViewController)
        resultSearchController?.searchResultsUpdater = locationsTableViewController
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = resultSearchController!.searchBar
        searchBar.placeholder = "搜索地址"
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
    }

    
    @IBAction func locationButtonAction(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    deinit {
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "latitude")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "longitude")
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
}
