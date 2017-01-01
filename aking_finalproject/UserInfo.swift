//
//  UserInfo.swift
//  aking_finalproject
//
//  Created by Allison King on 4/24/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import Foundation

struct UserInfo : PropertyListReadable {
    let currentLocation : LocationType
    let name : String
    let objID : String
    
    func propertyListRepresentation() -> NSDictionary {
        let representation : [String : AnyObject] = ["currentLocation" : currentLocation.rawValue, "name" : name, "objID" : objID]
        return representation
    }
    
    init(currentLocation : LocationType, name : String, objID : String) {
        self.currentLocation = currentLocation
        self.name = name
        self.objID = objID
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else {
            return nil
        }
        if let currentLocationRaw = values["currentLocation"] as? Int,
            name = values["name"] as? String,
            objID = values["objID"] as? String {
                let currentLocation = LocationType(rawValue: currentLocationRaw)!
                self.currentLocation = currentLocation
                self.name = name
                self.objID = objID
        }
        else {
            return nil
        }
    }
}





