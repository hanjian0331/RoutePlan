//
//  SearchLocationViewController.swift
//  RoutePlan
//
//  Created by hanjian on 2020/7/24.
//  Copyright © 2020 hanjian. All rights reserved.
//

import Pulley
import MapKit

protocol SearchLocationDelegate: class {
    var getMapView: MKMapView? { get }
    
}

class SearchLocationViewController: UIViewController {
    
    weak var delegate: SearchLocationDelegate?
    
    @IBOutlet var gripperView: UIView!
    @IBOutlet var gripperTopConstraint: NSLayoutConstraint!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            // We'll configure our UI to respect the safe area. In our small demo app, we just want to adjust the contentInset for the tableview.
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    var mapItems:[MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gripperView.layer.cornerRadius = 2.5

    }

}

extension SearchLocationViewController: PulleyDrawerViewControllerDelegate {

    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 68.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 264.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    // This function is called by Pulley anytime the size, drawer position, etc. changes. It's best to customize your VC UI based on the bottomSafeArea here (if needed). Note: You might also find the `pulleySafeAreaInsets` property on Pulley useful to get Pulley's current safe area insets in a backwards compatible (with iOS < 11) way. If you need this information for use in your layout, you can also access it directly by using `drawerDistanceFromBottom` at any time.
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat)
    {
        // We want to know about the safe area to customize our UI. Our UI customization logic is in the didSet for this variable.
        drawerBottomSafeArea = bottomSafeArea
        
        /*
         Some explanation for what is happening here:
         1. Our drawer UI needs some customization to look 'correct' on devices like the iPhone X, with a bottom safe area inset.
         2. We only need this when it's in the 'collapsed' position, so we'll add some safe area when it's collapsed and remove it when it's not.
         3. These changes are captured in an animation block (when necessary) by Pulley, so these changes will be animated along-side the drawer automatically.
         */
//        if drawer.drawerPosition == .collapsed
//        {
//            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
//        }
//        else
//        {
//            headerSectionHeightConstraint.constant = 68.0
//        }

        // Handle tableview scrolling / searchbar editing

        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel

        if drawer.drawerPosition != .open
        {
            searchBar.resignFirstResponder()
        }
//
//        if drawer.currentDisplayMode == .panel
//        {
//            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
//            bottomSeperatorView.isHidden = drawer.drawerPosition == .collapsed
//        }
//        else
//        {
//            topSeparatorView.isHidden = false
//            bottomSeperatorView.isHidden = true
//        }
    }
    
    /// This function is called when the current drawer display mode changes. Make UI customizations here.
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        
        gripperTopConstraint.isActive = drawer.currentDisplayMode == .drawer
    }
}

extension SearchLocationViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let mapView = delegate?.getMapView else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
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

extension SearchLocationViewController: UITableViewDelegate {
    
}

extension SearchLocationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let selectedItem = mapItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
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
}
