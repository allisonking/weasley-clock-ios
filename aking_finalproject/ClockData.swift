//
//  ClockData.swift
//  aking_finalproject
//
//  Created by Allison King on 4/9/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import Foundation
import MapKit
import Firebase

struct Point {
    let xcoord : Double
    let ycoord : Double
}

enum LocationType : Int{
    case workLocation
    case schoolLocation
    case exerciseLocation
    case homeLocation
    case unknown
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
        let representation : [String : AnyObject] = ["latitude" : coordinate.latitude as AnyObject, "longitude" : coordinate.longitude as AnyObject, "radius" : radius as AnyObject , "descriptor" : descriptor as AnyObject, "identifier" : identifier as AnyObject]
        return representation as NSDictionary
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
            let lon = values["longitude"] as? Double,
            let rad = values["radius"] as? Double,
            let desc = values["descriptor"] as? String,
            let id = values["identifier"] as? String {
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
    var ref: DatabaseReference!
    var myUserInfo : UserInfo?
    //let obj = PFObject(className: "aking_UserInfo")
    fileprivate var locations : [LocationInfo?] = Array(repeating: nil, count: numLocations)
    
    // default as unknown location
    var currentLocation : LocationType = .unknown {
        didSet {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.UserLocationChanged), object: self))
            // see if there is user info existing
            if let info = myUserInfo {
                // if there is user info, then update it in parse
                if currentLocation != oldValue {
                    print(info)
                    // update the entry
                    /*let query = PFQuery(className: "aking_UserInfo")
                    query.getObjectInBackground(withId: info.objID) { [weak self] (object, error) -> Void in
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
                    }*/
                    print("update info")

                    
                }
            }
            else {
                // otherwise, save to parse
                //obj.setValue(currentLocation.rawValue, forKey: "location")
                //obj.setValue("Tester", forKey: "name")
                ref = Database.database().reference(withPath: "user-info")
                let userInfo = UserInfo(currentLocation: currentLocation, name: "Me", objID: "Me")
                let userInfoRef = self.ref.child(userInfo.name)
                userInfoRef.setValue(userInfo.propertyListRepresentation())
                do {
                    //try obj.save()
//                    myUserInfo = UserInfo(currentLocation: currentLocation, name: "Tester", objID: obj.objectId!)
                    myUserInfo = UserInfo(currentLocation: currentLocation, name: "Tester", objID: "Me")
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
            if let loc = aDecoder.decodeObject(forKey: key) as? NSDictionary {
                locations[locationID] = LocationInfo(propertyListRepresentation: loc)
            } else {
                locations[locationID] = nil
            }
        }
        
        if let info = aDecoder.decodeObject(forKey: myUserInfoSaveKey) as? NSDictionary {
            myUserInfo = UserInfo(propertyListRepresentation: info)
        } else {
            myUserInfo = nil
        }
        
        super.init()
    }
    
    // Control exactly how this object will be saved to disk
    func encode(with aCoder: NSCoder) {
        for locationID in 0..<locations.count {
            let key = "loc" + String(locationID)
            aCoder.encode(locations[locationID]?.propertyListRepresentation(), forKey: key)
        }
        //aCoder.encodeObject(currentLocation?.rawValue, forKey: currentLocationKey)
        aCoder.encode(myUserInfo?.propertyListRepresentation(), forKey: myUserInfoSaveKey)
    }
    
    func setALocation(_ type : LocationType, locationInfo : LocationInfo) {
        locations[type.rawValue] = locationInfo

    }
    
    func getLocationInfo(_ type : LocationType) -> LocationInfo? {
        return locations[type.rawValue]
    }
    
    func getLocationTypeFromIdentifier(_ identifier : String) -> LocationType? {
        for locationID in 0..<locations.count {

            if locations[locationID]?.identifier == identifier {
                return LocationType(rawValue: locationID)
            }

        }
        return nil
    }

}

func getCoordinatesFromLocationType(_ type : LocationType ) -> Point {
    switch type {
    case .workLocation :
        return Point(xcoord: 0.0, ycoord: 1.0)
    case .schoolLocation :
        return Point(xcoord: sqrt(3)/2, ycoord: 0.5)
    case .exerciseLocation :
        return Point(xcoord: -sqrt(3)/2, ycoord: -0.5)
    case .homeLocation :
        return Point(xcoord: 0.0, ycoord: -1.0)
    case .unknown :
        return Point(xcoord: -sqrt(3)/2, ycoord: 0.5)
        // traveling: return Point(xcoord: sqrt(3)/2, ycoord: -0.5)
    }
}

