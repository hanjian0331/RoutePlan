//
//  MapViewController.swift
//  RoutePlan
//
//  Created by hanjian on 2020/7/15.
//  Copyright © 2020 hanjian. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
//    var destinations = [MKMapItem]()
    var nowLocation: MKMapItem?
    
    let waypointManager = WaypointManager()
    var selectedWaypoint: Waypoint?
    let mapPadding = UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60)
    let colors = [UIColor.systemRed,.systemGreen,.systemBlue,.systemOrange,.systemYellow,.systemPink,.systemPurple,.systemTeal,.systemPurple,.systemGray]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        waypointManager.delegate = self
        mapView.register(LabelMKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationIdentifier)
        
        let latitude = UserDefaults.standard.double(forKey: "latitude")
        let longitude = UserDefaults.standard.double(forKey: "longitude")
        if latitude != 0 && longitude != 0  {
            let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    
    @IBAction func locationButtonAction(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    deinit {
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "latitude")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "longitude")
    }
}

extension MapViewController : CLLocationManagerDelegate {
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
            
            nowLocation = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}

private let annotationIdentifier = "pin"
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //return nil for the user location to use the default view
        if annotation is MKUserLocation {
            return nil
        }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? LabelMKPinAnnotationView ?? LabelMKPinAnnotationView(annotation: nil, reuseIdentifier: annotationIdentifier)
        
        view.annotation = annotation
        view.animatesDrop = true
        view.canShowCallout = true
        
        
        if let waypoint = annotation as? Waypoint {
            updateView(view, for: waypoint)
        }
        
        return view
    }
    
    private func updateView(_ view: MKPinAnnotationView, for annotation: Waypoint) {
        let isStart = waypointManager.startWaypoint == annotation
        view.pinTintColor = isStart ? MKPinAnnotationView.greenPinColor() : MKPinAnnotationView.redPinColor()
        
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        guard let annotation = view.annotation else {
//            print("annotation view selected without an annoation")
//            return
//        }
//        guard let waypoint = annotation as? Waypoint else {
//            print("annotation \(annotation) selected which is not a waypoint")
//            return
//        }
//        selectWaypoint(waypoint)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        deselectWaypoint()
    }
    
    //route renderer
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        
        if let index = mapView.overlays.firstIndex(where: { return $0.isEqual(overlay) }) {
            renderer.strokeColor = colors[index % colors.count]
        }
        
        return renderer
    }
}

extension MapViewController: SearchLocationDelegate {

    var getMapView: MKMapView? {
        get {
            return mapView
        }
    }
    
    func addDestination(newDestination: MKMapItem) {
        let waypoint = Waypoint(location: newDestination.placemark.coordinate)
        waypointManager.add(waypoint)
    }
    
}

extension MapViewController: WaypointManagerDelegate {
    func didAdd(waypoint: Waypoint) {
        //index of the appended waypoint
//        let rowIndex = waypointManager.rowIndex(for: waypoint)!
        
        //update map
        mapView.addAnnotation(waypoint)
        //update table
//        waypointTableView.beginUpdates()
//        waypointTableView.insertRows(at: [rowIndex], withAnimation: NSTableView.AnimationOptions.slideDown)
//        waypointTableView.endUpdates()
    }
    
    func didUpdate(waypoint: Waypoint) {
        // update map
        if let view = mapView.view(for: waypoint) as? MKPinAnnotationView {
            updateView(view, for: waypoint)
        }
        
        //update table
//        guard let rowIndex = waypointManager.rowIndex(for: waypoint) else {
//            print("cannot update waypoint \(waypoint) which is not present in the model")
//            return
//        }
        
//        waypointTableView.reloadData(forRowIndexes: [rowIndex], columnIndexes: allColumnIndices)
    }
    
    func didCalcuate(routes: [Route], from source: Waypoint, to destination: Waypoint) {
        if let selectedWaypoint = selectedWaypoint {
            guard source == selectedWaypoint else {
                return
            }
        } else {
            mapView.removeOverlays(mapView.overlays)
        }
        
        routes.map{$0.polyline}.forEach(mapView.addOverlay)
    }
    
    func didCalucate(shortesPath: [Route]) {
//        deselectWaypoint()
        mapView.removeOverlays(mapView.overlays)
        let overlays = shortesPath.map {
            return $0.polyline
        }
        mapView.addOverlays(overlays)
        
        let mapRects = overlays.map({ $0.boundingMapRect })
        mapView.setVisibleMapRects(mapRects, edgePadding: mapPadding, animated: true)
        
        let routeSummary = RouteSummary(routes: shortesPath)
        let routeSteps = routeSummary.routeSteps(for: Date(), transferTime: 0)
//        routeSummaryController.routeSummary = routeSummary
        for waypoint in waypointManager.waypoints {
            if let view = mapView.view(for: waypoint) as? LabelMKPinAnnotationView {

                if let index = routeSteps.firstIndex(where: { $0.source == waypoint }) {
                    view.text = "\(index + 1)"
                }
                
            }
        }

        
    }
    
    func didChangeWaypointManagerState(from oldState: WaypointManagerState, to newState: WaypointManagerState) {
        
    }
    
    func willRemove(waypoint: Waypoint) {
        
    }
    
    func didRemove(waypoint: Waypoint) {
        
    }
    
    func resolveRouteCalculationErrorBetween(source: Waypoint, and destination: Waypoint, reason error: Error, resolve: @escaping (RouteCalculationResolveAction) -> ()) {
        
    }
    
    func didChangeRouteCalculationsProgress(progress: Double) {
        
    }
    
    
}

fileprivate extension WaypointManager {
    func rowIndex(for waypoint: Waypoint) -> Int? {
        return waypoints.firstIndex(of: waypoint)
    }
    func waypointForRow(at index: Int) -> Waypoint? {
        return waypoints[safe: index]
    }
}
