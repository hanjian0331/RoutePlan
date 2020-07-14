/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import MapKit

class DirectionsViewController: UIViewController {
  @IBOutlet private var mapView: MKMapView!
  @IBOutlet private var headerLabel: UILabel!
  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var informationLabel: UILabel!
  @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!

  private let cellIdentifier = "DirectionsCell"
  private let distanceFormatter = MKDistanceFormatter()

  private let route: Route

  private var mapRoutes: [MKRoute] = []
  private var totalTravelTime: TimeInterval = 0
  private var totalDistance: CLLocationDistance = 0

  private var groupedRoutes: [(startItem: MKMapItem, endItem: MKMapItem)] = []

  init(route: Route) {
    self.route = route

    super.init(nibName: String(describing: DirectionsViewController.self), bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    groupAndRequestDirections()

    headerLabel.text = route.label

    tableView.dataSource = self

    mapView.delegate = self
    mapView.showAnnotations(route.annotations, animated: false)
  }

  // MARK: - Helpers

  private func groupAndRequestDirections() {
    guard let firstStop = route.stops.first else {
      return
    }

    groupedRoutes.append((route.origin, firstStop))

    if route.stops.count == 2 {
      let secondStop = route.stops[1]

      groupedRoutes.append((firstStop, secondStop))
      groupedRoutes.append((secondStop, route.origin))
    }

    fetchNextRoute()
  }

  private func fetchNextRoute() {
    guard !groupedRoutes.isEmpty else {
      activityIndicatorView.stopAnimating()
      return
    }

    let nextGroup = groupedRoutes.removeFirst()
    let request = MKDirections.Request()

    request.source = nextGroup.startItem
    request.destination = nextGroup.endItem

    let directions = MKDirections(request: request)

    directions.calculate { response, error in
      guard let mapRoute = response?.routes.first else {
        self.informationLabel.text = error?.localizedDescription
        self.activityIndicatorView.stopAnimating()
        return
      }

      self.updateView(with: mapRoute)
      self.fetchNextRoute()
    }
  }

  private func updateView(with mapRoute: MKRoute) {
    let padding: CGFloat = 8
    mapView.addOverlay(mapRoute.polyline)
    mapView.setVisibleMapRect(
      mapView.visibleMapRect.union(
        mapRoute.polyline.boundingMapRect
      ),
      edgePadding: UIEdgeInsets(
        top: 0,
        left: padding,
        bottom: padding,
        right: padding
      ),
      animated: true
    )

    totalDistance += mapRoute.distance
    totalTravelTime += mapRoute.expectedTravelTime

    let informationComponents = [
      totalTravelTime.formatted,
      "• \(distanceFormatter.string(fromDistance: totalDistance))"
    ]
    informationLabel.text = informationComponents.joined(separator: " ")

    mapRoutes.append(mapRoute)
    tableView.reloadData()
  }
}

// MARK: - UITableViewDataSource

extension DirectionsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return mapRoutes.isEmpty ? 0 : mapRoutes.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let route = mapRoutes[section]
    return route.steps.count - 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = { () -> UITableViewCell in
      guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.selectionStyle = .none
        return cell
      }
      return cell
    }()

    let route = mapRoutes[indexPath.section]
    let step = route.steps[indexPath.row + 1]

    cell.textLabel?.text = "\(indexPath.row + 1): \(step.notice ?? step.instructions)"
    cell.detailTextLabel?.text = distanceFormatter.string(
      fromDistance: step.distance
    )

    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let route = mapRoutes[section]
    return route.name
  }
}

// MARK: - MKMapViewDelegate

extension DirectionsViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)

    renderer.strokeColor = .systemBlue
    renderer.lineWidth = 3

    return renderer
  }
}
