//
//  MapViewController.swift
//  aking_finalproject
//
//  Created by Allison King on 4/9/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import UIKit
import MapKit

let reuseID = "pin"
let MissingError = "Error Not Available"

var region: CLCircularRegion?

class MapViewController : UIViewController, UISearchBarDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    
    // rely on MyClockViewController to set this up
    var typeOfLocation : LocationType?
    
    // can fill in an initial location later
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    var localSearch: MKLocalSearch?
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var descriptorTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // closure- context in MyClockViewController
    var commitDescriptor: (String -> Void)?
    
    @IBAction func savePressed(sender: AnyObject) {
        guard let type = typeOfLocation else {
            preconditionFailure("Parent VC forgot to initialize our model :(")
        }
        
        // make sure to stop monitoring any regions that may have been saved before for this type
        if let oldInfo = userModel.getLocationInfo(type) {
            stopMonitoring(oldInfo)
        }
        
        // get the location of the pin (since pin is in the center of the map view)
        let coordinate = mapView.centerCoordinate
        let radius = (radiusTextField.text! as NSString).doubleValue
        let descriptor = descriptorTextField.text!
        let identifier = NSUUID().UUIDString
        
        // fill it all into a location info
        let locationInfo = LocationInfo(coordinate: coordinate, radius: radius, descriptor: descriptor, identifier: identifier)
        
        // update the model
        userModel.setALocation(type, locationInfo: locationInfo)

        
        startMonitoring(locationInfo)
        
        commitDescriptor?(descriptor)
        
        saveRegions()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func descriptionEdited(sender: AnyObject) {
        saveButton.enabled = checkIfFieldsFilledIn()
    }
    @IBAction func radiusEdited(sender: AnyObject) {

        // remove any existing overlays first
        removeOverlaysFromMap()
        
        // create the new one
        addOverlayToMap()
        
        saveButton.enabled = checkIfFieldsFilledIn()
    }
    
    func saveRegions() {
        let item = NSKeyedArchiver.archivedDataWithRootObject(userModel)
        NSUserDefaults.standardUserDefaults().setObject(item, forKey: saveKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        print("save successful!")
    }
    
    // determines if 'save' function should be enabled (if user has filled in all the necessary data)
    func checkIfFieldsFilledIn() -> Bool {
        if radiusTextField.text!.isEmpty || descriptorTextField.text!.isEmpty {
            return false
        }
        else {
            return true
        }
    }
    
    func addOverlayToMap() {
        let radius = (radiusTextField.text! as NSString).doubleValue
        let circleOverlay = MKCircle(centerCoordinate: mapView.centerCoordinate, radius: radius)
        mapView.addOverlay(circleOverlay)
    }
    
    func removeOverlaysFromMap() {
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
    }
    
    func updateUI() {
        let boundsMultiplier = 2.0
        guard let type = typeOfLocation else {
            preconditionFailure("Parent VC forgot to initialize our model :(")
        }
        if let locInfo = userModel.getLocationInfo(type) {
            radiusTextField.text = "\(locInfo.radius)"
            descriptorTextField.text = locInfo.descriptor
            mapView.centerCoordinate = locInfo.coordinate
            let bounds = locInfo.radius * boundsMultiplier
            let region = MKCoordinateRegionMakeWithDistance(
                mapView.centerCoordinate, bounds, bounds);
            mapView.setRegion(region, animated: true)
            addOverlayToMap()
            
        }
        
        saveButton.enabled = checkIfFieldsFilledIn()
        
    }
    
    //var myLocation : CLLocation?
    
    var locationManager : CLLocationManager?
    
    
    // MARK: functions for geofencing
    
    // get the region from the location
    func getRegionFromLocationInfo(loc : LocationInfo) -> CLCircularRegion {
        let reg = CLCircularRegion(center: loc.coordinate, radius: loc.radius, identifier: loc.identifier)
        reg.notifyOnEntry = true
        reg.notifyOnExit = true
        return reg
    }
    
    func startMonitoring(var loc : LocationInfo) {
        guard let type = typeOfLocation else {
            preconditionFailure("parent forgot to say what type we were")
        }
        // have to adjust the radius if it is bigger than max monitoring distance
        var adjustedRadius = loc.radius
        if let maxRadius = locationManager?.maximumRegionMonitoringDistance{
            if adjustedRadius > maxRadius {
                adjustedRadius = maxRadius
                loc.radius = adjustedRadius
            }
        }

        region = getRegionFromLocationInfo(loc)
        locationManager?.startMonitoringForRegion(region!)
        
        
        if (region!.containsCoordinate(mapView.userLocation.coordinate)) {
            userModel.currentLocation = type
        }
        else {
            AppDel.checkAndSetLocations(mapView.userLocation.coordinate)
        }
        
    }
    
    func stopMonitoring(loc : LocationInfo) {
        // loop through the regions and delete the correct one
        if let locManager = locationManager {
            for region in locManager.monitoredRegions {
                if let circularRegion = region as? CLCircularRegion {
                    if circularRegion.identifier == loc.identifier {
                        locationManager?.stopMonitoringForRegion(circularRegion)
                    }
                }
            }
        } else {
            preconditionFailure("location manager not set up")
        }
    }
    
    // MARK: the model
    var userModel = AppDel.userModel
    
    // MARK: View did load
    override func viewDidLoad() {
        radiusTextField.delegate = self
        descriptorTextField.delegate = self
        searchBar!.delegate = self
        mapView.delegate = self
        locationManager = AppDel.locationManager
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            mapView.showsUserLocation = true
        }
        
        updateUI()
        locationManager?.requestLocation()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        locationManager?.requestAlwaysAuthorization()
    }
    
    // dismisses the keyboard after finished editing a text field
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Map View Delegate for how to draw overlay
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.blueColor()
            circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.4)
            return circleRenderer
        }
        else {
            return MKCircleRenderer()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let search = localSearch {
            search.cancel()
        }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        
        localSearch = MKLocalSearch(request: request)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        localSearch!.startWithCompletionHandler { [weak self] (response: MKLocalSearchResponse?, error: NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            guard let response = response else {
                print("error in search: \(error?.localizedDescription ?? MissingError)")
                return
            }
            guard let firstLoc = response.mapItems.first else {
                print("Got 0 results")
                return
            }
            self?.updateMap(firstLoc, region: response.boundingRegion)
        }
        
        // dismiss keyboard after search
        searchBar.resignFirstResponder()
        
    }
    
    func updateMap(item: MKMapItem, region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
    
}
