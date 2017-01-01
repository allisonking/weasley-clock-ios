//
//  ClockData.swift
//  aking_finalproject
//
//  Created by Allison King on 4/9/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import Foundation
import MapKit

struct Point {
    let xcoord : Double
    let ycoord : Double
}

enum LocationType : Int{
    case WorkLocation
    case SchoolLocation
    case ExerciseLocation
    case HomeLocation
    case Unknown
}

// idea from http://redqueencoder.com/property-lists-and-user-defaults-in-swift/
protocol PropertyListReadable {
    func propertyListRepresentation() -> NSDictionary
    init?(propertyListRepresentation : NSDictionary? )
}

struct LocationInfo : PropertyListReadable {
    let coordinate : CLLocationCoordinate2D
    var radius : Double
    let descriptor : String
    let identifier : String
    
    func propertyListRepresentation() -> NSDictionary {
        let representation : [String : AnyObject] = ["latitude" : coordinate.latitude, "longitude" : coordinate.longitude, "radius" : radius , "descriptor" : descriptor, "identifier" : identifier]
        return representation
    }
    
    init(coordinate : CLLocationCoordinate2D, radius: Double, descriptor : String, identifier : String) {
        self.coordinate = coordinate
        self.radius = radius
        self.descriptor = descriptor
        self.identifier = identifier
    }
    
    init?(propertyListRepresentation : NSDictionary?) {
        guard let values = propertyListRepresentation else {
            return nil
        }
        if let lat = values["latitude"] as? Double,
            lon = values["longitude"] as? Double,
            rad = values["radius"] as? Double,
            desc = values["descriptor"] as? String,
            id = values["identifier"] as? String {
                let coord = CLLocationCoordinate2DMake(lat, lon)
                self.coordinate = coord
                self.radius = rad
                self.descriptor = desc
                self.identifier = id
        } else {
            return nil
        }
    }
    
}



let numLocations = 6 // including travel and unknown- should be the same size as the number of location types
let currentLocationKey = "currentLocation"
class ClockData : NSObject, NSCoding {
    var myUserInfo : UserInfo?
    let obj = PFObject(className: "aking_UserInfo")
    private var locations : [LocationInfo?] = Array(count: numLocations, repeatedValue: nil)
    
    // default as unknown location
    var currentLocation : LocationType = .Unknown {
        didSet {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Messages.UserLocationChanged, object: self))
            // see if there is user info existing
            if let info = myUserInfo {
                // if there is user info, then update it in parse
                if currentLocation != oldValue {
                    // update the entry
                    let query = PFQuery(className: "aking_UserInfo")
                    query.getObjectInBackgroundWithId(info.objID) { [weak self] (object, error) -> Void in
                        guard let s = self else {
                            // not really sure what to do here...
                            print("clock data dismissed???")
                            return
                        }
                        if let e = error {
                            print("error: \(e.localizedDescription)")
                            return
                        }
                        if let result = object {
                            result["location"] = s.currentLocation.rawValue
                            result.saveInBackground()
                        }
                    }
                }
            }
            else {
                // otherwise, save to parse
                obj.setValue(currentLocation.rawValue, forKey: "location")
                obj.setValue("Tester", forKey: "name")
                
                do {
                    try obj.save()
                    myUserInfo = UserInfo(currentLocation: currentLocation, name: "Tester", objID: obj.objectId!)
                }
                catch let e as NSError {
                    print(e.localizedDescription)
                }

            }
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        for locationID in 0..<locations.count {
            let key = "loc" + String(locationID)
            if let loc = aDecoder.decodeObjectForKey(key) as? NSDictionary {
                locations[locationID] = LocationInfo(propertyListRepresentation: loc)
            } else {
                locations[locationID] = nil
            }
        }
        
        if let info = aDecoder.decodeObjectForKey(myUserInfoSaveKey) as? NSDictionary {
            myUserInfo = UserInfo(propertyListRepresentation: info)
        } else {
            myUserInfo = nil
        }
        
        super.init()
    }
    
    // Control exactly how this object will be saved to disk
    func encodeWithCoder(aCoder: NSCoder) {
        for locationID in 0..<locations.count {
            let key = "loc" + String(locationID)
            aCoder.encodeObject(locations[locationID]?.propertyListRepresentation(), forKey: key)
        }
        //aCoder.encodeObject(currentLocation?.rawValue, forKey: currentLocationKey)
        aCoder.encodeObject(myUserInfo?.propertyListRepresentation(), forKey: myUserInfoSaveKey)
    }
    
    func setALocation(type : LocationType, locationInfo : LocationInfo) {
        locations[type.rawValue] = locationInfo

    }
    
    func getLocationInfo(type : LocationType) -> LocationInfo? {
        return locations[type.rawValue]
    }
    
    func getLocationTypeFromIdentifier(identifier : String) -> LocationType? {
        for locationID in 0..<locations.count {

            if locations[locationID]?.identifier == identifier {
                return LocationType(rawValue: locationID)
            }

        }
        return nil
    }

}

func getCoordinatesFromLocationType(type : LocationType ) -> Point {
    switch type {
    case .WorkLocation :
        return Point(xcoord: 0.0, ycoord: 1.0)
    case .SchoolLocation :
        return Point(xcoord: sqrt(3)/2, ycoord: 0.5)
    case .ExerciseLocation :
        return Point(xcoord: -sqrt(3)/2, ycoord: -0.5)
    case .HomeLocation :
        return Point(xcoord: 0.0, ycoord: -1.0)
    case .Unknown :
        return Point(xcoord: -sqrt(3)/2, ycoord: 0.5)
        // traveling: return Point(xcoord: sqrt(3)/2, ycoord: -0.5)
    }
}

