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
    
    fileprivate var userDataObserver : NSObjectProtocol?
    
    deinit {
        if let obs = userDataObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
    
    var userModel = AppDel.userModel
    
    fileprivate func updateUI() {
        // update the hand of the clock
        myHandsView.setNeedsDisplay()
        
        // update the button text
        updateButtonText(workSet, type: .workLocation)
        updateButtonText(homeSet, type: .homeLocation)
        updateButtonText(schoolSet, type: .schoolLocation)
        updateButtonText(exerciseSet, type: .exerciseLocation)
    }
    
    /*
    * If the user has set a location before, set the button to the location's descriptor
    * Otherwise, set the button to say 'Set'
    */
    fileprivate func updateButtonText(_ button : UIButton, type : LocationType) {
        if let loc = userModel.getLocationInfo(type) {
            button.setTitle(loc.descriptor, for: UIControlState())
        } else {
            button.setTitle("Set", for: UIControlState())
        }
    }
    
    override func viewDidLoad() {
        // if notification that user location changed was received, update the UI
        userDataObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Messages.UserLocationChanged), object: userModel, queue: OperationQueue.main) {
            [weak self] (notification: Notification) in
            self?.updateUI()
        }
        
        // set the hands view model
        myHandsView.userModel = userModel
        updateUI()
    }
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // the destination view controller needs to know which location it is working with
        var locationToChange : LocationType
        
        // get which button was pressed
        guard let tappedButton = sender as? UIButton else {
            preconditionFailure("Segue from unexpeced object: \(sender)")
        }
        
        // get the next view (destination view controller)
        guard let editLocationVC = segue.destination as? MapViewController else {
            preconditionFailure("Wrong destination type: \(segue.destination)")
        }
        
        // set the type of location based on which button was pressed
        switch tappedButton {
        case workSet:
            locationToChange = .workLocation
        case homeSet :
            locationToChange = .homeLocation
        case schoolSet:
            locationToChange = .schoolLocation
        case exerciseSet:
            locationToChange = .exerciseLocation
        default :
            preconditionFailure("Unexpected button press segue")
        }
        
        // pass this information on to the destination view controller
        editLocationVC.typeOfLocation = locationToChange
        
        // change the name of the button to the descriptor of the location the user put in
        editLocationVC.commitDescriptor = { (descriptor : String) in
            tappedButton.setTitle(descriptor, for: UIControlState())
        }
        
    }
    
}
