//
//  SearchResultTableView.swift
//  RoutePlan
//
//  Created by hanjian on 2020/7/12.
//  Copyright © 2020 hanjian. All rights reserved.
//

import UIKit

class SearchResultTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var tableData = [AMapTip]()
    var didSelectTip: ((AMapTip)->())?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        let tip = tableData[indexPath.row]
        if (didSelectTip != nil) {
            didSelectTip!(tip)
        }
        
//        if tip.location != nil {
//            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(tip.location.latitude), longitude: CLLocationDegrees(tip.location.longitude))
//            let anno = MAPointAnnotation()
//            anno.coordinate = coordinate
//            anno.title = tip.name
//            anno.subtitle = tip.address
//
//            mapView.addAnnotation(anno)
//            mapView.selectAnnotation(anno, animated: true)
//        }
//
//        searchController.isActive = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    //MARK:- TableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultTableViewCellIdentifier"
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if !tableData.isEmpty {
            
            let tip = tableData[indexPath.row]
            
            cell!.textLabel?.text = tip.name
            cell!.detailTextLabel?.text = tip.address
        }
        
        return cell!
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}
