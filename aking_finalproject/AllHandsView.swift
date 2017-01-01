//
//  AllHandsView.swift
//  aking_finalproject
//
//  Created by Allison King on 4/24/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import UIKit


class AllHandsView : UIView {
    let offset = 0.75
    let adjustRatio = 0.1
    private var userDataObserver : NSObjectProtocol?
    
    var socialModel : SocialClockData?
    
    override func drawRect(rect: CGRect) {
        // make sure we have the model
        guard let model = socialModel else {
            preconditionFailure("parent did not instantiate user model!")
        }
        // get the current location of the user
        for index in 0..<model.allUserInfo.count {
            let color = getColorFromIndex(index)
            color.set()
            if let info = model.allUserInfo[index] {
                let adjustedOffset = offset - Double(index) * adjustRatio
                drawHand(info.currentLocation, lengthOffset: adjustedOffset)
            }
        }
        
    }
    
    func drawHand(currentLocation : LocationType, lengthOffset : Double) {
        // get the coordinates for a certain location type (i.e. 'Work' should point straight up)
        let modifier = getCoordinatesFromLocationType(currentLocation)
        
        let height = bounds.height
        let width = bounds.width
        
        // how long the clock hand should be
        let radius = Double(height)/2 * lengthOffset
        
        // center of the clock
        let centerY = height/2
        let centerX = width/2
        
        // draw the clock hand
        let clockHand = UIBezierPath()
        clockHand.moveToPoint(CGPoint(x: centerX, y: centerY))
        clockHand.addLineToPoint(CGPoint(x: Double(centerX) + radius * modifier.xcoord, y: Double(centerY) + radius * modifier.ycoord))
        //UIColor.blackColor().set()
        clockHand.lineWidth = 3
        clockHand.stroke()
    }
    
}

func getColorFromIndex(index : Int) -> UIColor {
    switch index {
    case 0:
        return UIColor.redColor()
    case 1:
        return UIColor.orangeColor()
    case 2:
        return UIColor.yellowColor()
    case 3:
        return UIColor.greenColor()
    case 4:
        return UIColor.blueColor()
    case 5:
        return UIColor.purpleColor()
    default :
        return UIColor.blackColor()
    }
}