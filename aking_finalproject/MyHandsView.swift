//
//  ClockView.swift
//  aking_finalproject
//
//  Created by Allison King on 3/23/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import UIKit


class MyHandsView : UIView {
    let offset = 0.75
    fileprivate var userDataObserver : NSObjectProtocol?
    
    var userModel : ClockData?
    
    override func draw(_ rect: CGRect) {
        // make sure we have the model
        guard let model = userModel else {
            preconditionFailure("parent did not instantiate user model!")
        }
        
            // get the coordinates for a certain location type (i.e. 'Work' should point straight up)
            let modifier = getCoordinatesFromLocationType(model.currentLocation)
            
            let height = bounds.height
            let width = bounds.width

            // how long the clock hand should be
            let radius = Double(height)/2 * offset
            
            // center of the clock
            let centerY = height/2
            let centerX = width/2
            
            // draw the clock hand
            let clockHand = UIBezierPath()
            clockHand.move(to: CGPoint(x: centerX, y: centerY))
            clockHand.addLine(to: CGPoint(x: Double(centerX) + radius * modifier.xcoord, y: Double(centerY) + radius * modifier.ycoord))
            UIColor.black.set()
            clockHand.lineWidth = 3
            clockHand.stroke()
        

    }
    
}
