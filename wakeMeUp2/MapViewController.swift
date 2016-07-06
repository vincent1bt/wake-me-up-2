//
//  MapViewController.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 6/27/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,  MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, APIFoursquareProtocol {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var tableHidden: Bool = false
    var locationManager: CLLocationManager!
    let distanceSpan: Double = 500.0
    var places: [Place] = []
    var annotations: [FoodAnnotation] = []
    
    override func viewDidLoad() {
        FoursquareRequest.delegate = self
        super.viewDidLoad()
        self.configTable()
        self.configfMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - table
    
    func configTable() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placesCell", forIndexPath: indexPath)
        let place = self.places[indexPath.row]
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.text = place.name
        cell.detailTextLabel?.text = place.address
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let place = self.places[indexPath.row]
        let region = MKCoordinateRegionMakeWithDistance(place.coordinate, distanceSpan, distanceSpan)
        self.mapView.setRegion(region, animated: true)
        self.mapView.selectAnnotation(self.annotations[indexPath.row], animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRectMake(10, 7.5, tableView.frame.size.width, 20))
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 0.98)
        label.text = "Lugares"
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 35))
        view.addSubview(label)
        view.backgroundColor = UIColor.init(red: 236/255, green: 240/255, blue: 241/255, alpha: 0.98)
        return view
    }
    
    //MARK: - Buttons
    
    @IBAction func cancelButton(sender: UIButton) {
        self.mapView.removeOverlays(self.mapView.overlays)
        self.cancelButton.hidden = true
        self.cancelButton.enabled = false
        for annotation in self.mapView.annotations {
            if annotation.isKindOfClass(FoodAnnotation.self) {
                self.mapView.viewForAnnotation(annotation)?.hidden = false
            }
        }
    }
    
    @IBAction func positionButton(sender: UIButton) {
        self.getUserLocation()
    }
    
    @IBAction func expandButton(sender: UIButton) {
        let tableHeight: CGFloat = 227.0
        UIView.animateWithDuration(0.5) {
            if self.tableHidden {
                self.tableViewBottomConstraint.constant += tableHeight
                self.tableHidden = false
            } else {
                self.tableViewBottomConstraint.constant -= tableHeight
                self.tableHidden = true
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Map
    
    func configfMap() {
        self.cancelButton.hidden = true
        self.cancelButton.enabled = false
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }
    
    func getUserLocation() {
        let userLocation = self.mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, distanceSpan, distanceSpan)
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
        self.mapView.setRegion(region, animated: true)
        FoursquareRequest.sharedInstance.getPlaces(newLocation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        let identifier = "annotationIdentifier"
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        view?.canShowCallout = true
        let btn = UIButton(type: .InfoDark)
        view?.rightCalloutAccessoryView = btn
        return view
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.init(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        renderer.lineWidth = 4.5
        return renderer
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        for annotation in self.mapView.annotations {
            let actualAnnotation = view.annotation!
            
            if annotation.isKindOfClass(FoodAnnotation.self) {
                self.mapView.viewForAnnotation(annotation)?.hidden = true
            }
            
            if actualAnnotation === annotation {
                self.mapView.viewForAnnotation(annotation)?.hidden = false
            }
        }
        
        self.mapView.removeOverlays(self.mapView.overlays)
        let destination = view.annotation?.coordinate
        let mark = MKPlacemark(coordinate: destination!, addressDictionary: nil)
        let destinationItem = MKMapItem(placemark: mark)
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destinationItem
        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            guard error == nil else {
                print("Error con las rutas")
                return
            }
            self.showRoute(response!)
        }
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes {
            self.mapView.addOverlay(route.polyline, level: .AboveRoads)
            for step in route.steps {
                print(step)
            }
        }
        self.cancelButton.enabled = true
        self.cancelButton.hidden = false
        getUserLocation()
    }
    
    
    func didRecieveAPIResults(places: [Place], annotations: [FoodAnnotation]) {
        self.places.appendContentsOf(places)
        self.annotations = annotations
        self.mapView.addAnnotations(annotations)
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
    }

}
