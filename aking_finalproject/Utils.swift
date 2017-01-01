//
//  Utils.swift
//  aking_finalproject
//
//  Created by Allison King on 4/16/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import Foundation
import MapKit
extension CLRegion {
    private var _locationType : LocationType
    var locationType : LocationType {
        get {
            return LocationType.WorkLocation
        }
        set {
            locationType = newValue
        }
    }
    
}
