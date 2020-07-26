//
//  MKMapView+extension.swift
//  traveling-salesman-problem
//
//  Created by David Nadoba on 13/02/2017.
//  Copyright © 2017 David Nadoba. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func setVisibleMapRects(_ mapRects: [MKMapRect], animated: Bool) {
        setVisibleMapRects(mapRects, edgePadding: .init(), animated: animated)
    }
    #if canImport(UIKit)
    func setVisibleMapRects(_ mapRects: [MKMapRect], edgePadding: UIEdgeInsets, animated: Bool) {
        if let firstMapRect = mapRects.first {
            let unionMapRect = mapRects.dropFirst().reduce(into: firstMapRect) { (result, rect2) in
                result.union(rect2)
            }
            setVisibleMapRect(unionMapRect, edgePadding: edgePadding, animated: animated)
        }
    }
    
    #elseif canImport(AppKit)
    func setVisibleMapRects(_ mapRects: [MKMapRect], edgePadding: NSEdgeInsets, animated: Bool) {
        if let firstMapRect = mapRects.first {
            let unionMapRect = mapRects.dropFirst().reduce(into: firstMapRect) { (result, rect2) in
                result.union(rect2)
            }
            setVisibleMapRect(unionMapRect, edgePadding: edgePadding, animated: animated)
        }
    }
    #endif

}
