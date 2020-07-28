//
//  LabelMKPinAnnotationView.swift
//  RoutePlan
//
//  Created by hanjian on 2020/7/28.
//  Copyright © 2020 hanjian. All rights reserved.
//

import MapKit

class LabelMKPinAnnotationView: MKPinAnnotationView {
 
    var text: String? {
        didSet {
            dot.text = text
            dot.sizeToFit()
            dot.frame = dot.frame.insetBy(dx: -2, dy: -2)
            dot.frame.origin.x = -0.5 * dot.frame.width + 8
            dot.center.y = -0.5 * dot.frame.height
        }
    }
    
    private let dot = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        dot.textAlignment = .center
        dot.backgroundColor = UIColor.lightGray
//        dot.layer.borderColor = UIColor.darkGray.cgColor
//        dot.layer.borderWidth = 2
        dot.layer.cornerRadius = 5
        dot.layer.masksToBounds = true
        addSubview(dot)
    }
}
