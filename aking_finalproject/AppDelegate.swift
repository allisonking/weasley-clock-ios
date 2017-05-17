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
        return UIApplication.shared.delegate as! AppDelegate
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    fileprivate var checkLocations = false
    
    fileprivate var _userModel = ClockData()
    var userModel : ClockData {
        get {
            return _userModel
        }
    }
    
    fileprivate var _socialModel = SocialClockData()
    var socialModel : SocialClockData {
        get {
            return _socialModel
        }
    }
    
    fileprivate var _myUserInfo : UserInfo? = nil
    var myUserInfo : UserInfo? {
        get {
            return _myUserInfo
        }
    }
    
    let locationManager = CLLocationManager()
    
    var myLocation : CLLocation?
    
    // MARK: location manager delegate
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            print("geofence entered")
        }
    }
    
    func updateMyLocation() {
        locationManager.requestLocation()
        print("from exit geofence: \(myLocation)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

        if region is CLCircularRegion {
            print("geofence exited")
        }
        
        checkLocations = true
        locationManager.requestLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if region is CLCircularRegion && state == .inside {
            print("I am in the region \(userModel.getLocationTypeFromIdentifier(region.identifier))")
            // update the model!
            if let loc = userModel.getLocationTypeFromIdentifier(region.identifier) {
                userModel.currentLocation = loc
            }
            else {
                userModel.currentLocation = .unknown
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations[0]
        print("I am at \(myLocation)")
        
        if checkLocations {
            checkLocations = false
            if let loc = myLocation{
                checkAndSetLocations(loc.coordinate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("I failed to get location because: \(error.localizedDescription)")
    }
    
    func checkAndSetLocations(_ loc : CLLocationCoordinate2D) {
        var unknownLocation = true
        for area in locationManager.monitoredRegions {
            if let a = area as? CLCircularRegion {
                if a.contains(loc) {
                    unknownLocation = false
                    // might want to do radius checking too...
                    if let loc = userModel.getLocationTypeFromIdentifier(a.identifier) {
                        userModel.currentLocation = loc
                    }

                }
            }
        }
        
        if unknownLocation {
            userModel.currentLocation = .unknown
        }
    }
    
    func loadAllRegions() {
        if let savedObj = UserDefaults.standard.object(forKey: saveKey) {
            if let data = NSKeyedUnarchiver.unarchiveObject(with: savedObj as! Data) as? ClockData {
                print("got something!")
                _userModel = data
                
                // check where to point the clock
                checkLocations = true
            }
        }
    }
    
    func loadAllUserInfo() {
  
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
        
        /*let configuration = ParseClientConfiguration {
            $0.applicationId = "Spring2016"
            $0.clientKey = "E65Parse"
            $0.server = "http://student.classyswift.com:1337/parse"
        }
        Parse.initialize(with: configuration)*/
        
        FIRApp.configure()
       
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

