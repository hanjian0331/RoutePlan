//
//  ViewController.swift
//  SearchCompleter
//
//  Created by hanjian on 2020/7/13.
//  Copyright © 2020 hanjian. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController {

    private let completer = MKLocalSearchCompleter()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        completer.delegate = self
        completer.queryFragment = "浙江大学"
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

// MARK: - MKLocalSearchCompleterDelegate

extension ViewController: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    for completio in completer.results {
        print(completio.title)
        
        print(completio.subtitle)
    }
  }

  func completer(
    _ completer: MKLocalSearchCompleter,
    didFailWithError error: Error
  ) {
    print("Error suggesting a location: \(error.localizedDescription)")
  }
}
