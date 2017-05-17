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
    fileprivate var userDataObserver : NSObjectProtocol?
    
    var socialModel : SocialClockData?
    
    override func draw(_ rect: CGRect) {
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
    
    func drawHand(_ currentLocation : LocationType, lengthOffset : Double) {
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
        clockHand.move(to: CGPoint(x: centerX, y: centerY))
        clockHand.addLine(to: CGPoint(x: Double(centerX) + radius * modifier.xcoord, y: Double(centerY) + radius * modifier.ycoord))
        //UIColor.blackColor().set()
        clockHand.lineWidth = 3
        clockHand.stroke()
    }
    
}

func getColorFromIndex(_ index : Int) -> UIColor {
    switch index {
    case 0:
        return UIColor.red
    case 1:
        return UIColor.orange
    case 2:
        return UIColor.yellow
    case 3:
        return UIColor.green
    case 4:
        return UIColor.blue
    case 5:
        return UIColor.purple
    default :
        return UIColor.black
    }
}
