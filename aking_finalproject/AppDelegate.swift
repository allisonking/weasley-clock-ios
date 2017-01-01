//
//  AppDelegate.swift
//  aking_finalproject
//
//  Created by Allison King on 3/23/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import UIKit
import MapKit

let saveKey = "userClockData"
let myUserInfoSaveKey = "myUserInfo"
let allFriendsSaveKey = "allFriends"

var AppDel : AppDelegate {
    get {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    private var checkLocations = false
    
    private var _userModel = ClockData()
    var userModel : ClockData {
        get {
            return _userModel
        }
    }
    
    private var _socialModel = SocialClockData()
    var socialModel : SocialClockData {
        get {
            return _socialModel
        }
    }
    
    private var _myUserInfo : UserInfo? = nil
    var myUserInfo : UserInfo? {
        get {
            return _myUserInfo
        }
    }
    
    let locationManager = CLLocationManager()
    
    var myLocation : CLLocation?
    
    // MARK: location manager delegate
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("geofence entered")
        }
    }
    
    func updateMyLocation() {
        locationManager.requestLocation()
        print("from exit geofence: \(myLocation)")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {

        if region is CLCircularRegion {
            print("geofence exited")
        }
        
        checkLocations = true
        locationManager.requestLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        if region is CLCircularRegion && state == .Inside {
            print("I am in the region \(userModel.getLocationTypeFromIdentifier(region.identifier))")
            // update the model!
            if let loc = userModel.getLocationTypeFromIdentifier(region.identifier) {
                userModel.currentLocation = loc
            }
            else {
                userModel.currentLocation = .Unknown
            }
        }
    }

    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations[0]
        print("I am at \(myLocation)")
        
        if checkLocations {
            checkLocations = false
            if let loc = myLocation{
                checkAndSetLocations(loc.coordinate)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("I failed to get location because: \(error.localizedDescription)")
    }
    
    func checkAndSetLocations(loc : CLLocationCoordinate2D) {
        var unknownLocation = true
        for area in locationManager.monitoredRegions {
            if let a = area as? CLCircularRegion {
                if a.containsCoordinate(loc) {
                    unknownLocation = false
                    // might want to do radius checking too...
                    if let loc = userModel.getLocationTypeFromIdentifier(a.identifier) {
                        userModel.currentLocation = loc
                    }

                }
            }
        }
        
        if unknownLocation {
            userModel.currentLocation = .Unknown
        }
    }
    
    func loadAllRegions() {
        if let savedObj = NSUserDefaults.standardUserDefaults().objectForKey(saveKey) {
            if let data = NSKeyedUnarchiver.unarchiveObjectWithData(savedObj as! NSData) as? ClockData {
                print("got something!")
                _userModel = data
                
                // check where to point the clock
                checkLocations = true
            }
        }
    }
    
    func loadAllUserInfo() {
  
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        loadAllRegions()
        locationManager.requestLocation()
        for region in locationManager.monitoredRegions {
            print(region.identifier)
            //locationManager.stopMonitoringForRegion(region)
        }
      
        
        //locationManager.startUpdatingLocation()
        // Override point for customization after application launch.
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "Spring2016"
            $0.clientKey = "E65Parse"
            $0.server = "http://student.classyswift.com:1337/parse"
        }
        Parse.initializeWithConfiguration(configuration) 
       
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

