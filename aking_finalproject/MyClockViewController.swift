//
//  MyClockViewController.swift
//  aking_finalproject
//
//  Created by Allison King on 4/9/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import UIKit

class MyClockViewController : UIViewController {
    @IBOutlet weak var workSet: UIButton!
    @IBOutlet weak var homeSet: UIButton!
    @IBOutlet weak var schoolSet: UIButton!
    @IBOutlet weak var exerciseSet: UIButton!
    
    @IBOutlet weak var myHandsView: MyHandsView!
    
    private var userDataObserver : NSObjectProtocol?
    
    deinit {
        if let obs = userDataObserver {
            NSNotificationCenter.defaultCenter().removeObserver(obs)
        }
    }
    
    var userModel = AppDel.userModel
    
    private func updateUI() {
        // update the hand of the clock
        myHandsView.setNeedsDisplay()
        
        // update the button text
        updateButtonText(workSet, type: .WorkLocation)
        updateButtonText(homeSet, type: .HomeLocation)
        updateButtonText(schoolSet, type: .SchoolLocation)
        updateButtonText(exerciseSet, type: .ExerciseLocation)
    }
    
    /*
    * If the user has set a location before, set the button to the location's descriptor
    * Otherwise, set the button to say 'Set'
    */
    private func updateButtonText(button : UIButton, type : LocationType) {
        if let loc = userModel.getLocationInfo(type) {
            button.setTitle(loc.descriptor, forState: .Normal)
        } else {
            button.setTitle("Set", forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        // if notification that user location changed was received, update the UI
        userDataObserver = NSNotificationCenter.defaultCenter().addObserverForName(Messages.UserLocationChanged, object: userModel, queue: NSOperationQueue.mainQueue()) {
            [weak self] (notification: NSNotification) in
            self?.updateUI()
        }
        
        // set the hands view model
        myHandsView.userModel = userModel
        updateUI()
    }
    
    // MARK: Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // the destination view controller needs to know which location it is working with
        var locationToChange : LocationType
        
        // get which button was pressed
        guard let tappedButton = sender as? UIButton else {
            preconditionFailure("Segue from unexpeced object: \(sender)")
        }
        
        // get the next view (destination view controller)
        guard let editLocationVC = segue.destinationViewController as? MapViewController else {
            preconditionFailure("Wrong destination type: \(segue.destinationViewController)")
        }
        
        // set the type of location based on which button was pressed
        switch tappedButton {
        case workSet:
            locationToChange = .WorkLocation
        case homeSet :
            locationToChange = .HomeLocation
        case schoolSet:
            locationToChange = .SchoolLocation
        case exerciseSet:
            locationToChange = .ExerciseLocation
        default :
            preconditionFailure("Unexpected button press segue")
        }
        
        // pass this information on to the destination view controller
        editLocationVC.typeOfLocation = locationToChange
        
        // change the name of the button to the descriptor of the location the user put in
        editLocationVC.commitDescriptor = { (descriptor : String) in
            tappedButton.setTitle(descriptor, forState: .Normal)
        }
        
    }
    
}
