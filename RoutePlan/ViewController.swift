//
//  ViewController.swift
//  RoutePlan
//
//  Created by hanjian on 2020/7/11.
//  Copyright © 2020 hanjian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let search = AMapSearchAPI()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        search?.delegate = self
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let startCoordinate        = CLLocationCoordinate2DMake(30.307931, 120.106573)
//        let destinationCoordinate  = CLLocationCoordinate2DMake(30.003875, 120.573213)
//
//        let request = AMapDrivingRouteSearchRequest()
//        request.origin = AMapGeoPoint.location(withLatitude: CGFloat(startCoordinate.latitude), longitude: CGFloat(startCoordinate.longitude))
//        request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationCoordinate.latitude), longitude: CGFloat(destinationCoordinate.longitude))
//
//        request.requireExtension = true
//        search?.aMapDrivingRouteSearch(request)
        
        let request = AMapInputTipsSearchRequest()
        request.keywords = "浙江大学"
        search?.aMapInputTipsSearch(request)
    }
}

extension ViewController: AMapSearchDelegate {
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        if response.count > 0 {
            //解析response获取路径信息
        }
    }
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        if response.count == 0 {
            return
        }
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("Error:\(String(describing: error))")
    }
}
