//
//  ObservingVC.swift
//  aking_finalproject
//
//  Created by Allison King on 4/26/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import UIKit

func globalErrorAlert(vc: UIViewController, message: String, title: String = "Alert", completion: (() -> ())? = nil) {
    //Util.log("User was alerted: \(message)")
    let alertBox = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    alertBox.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in completion?() }))
    vc.presentViewController(alertBox, animated: true, completion: nil)
}


class ObservingVC: UIViewController {
    func errorAlert( message: String, title: String = "Alert", completion: (() -> ())? = nil) {
        globalErrorAlert(self, message: message, title: title, completion: completion)
    }
}

class ObservingTVC: UITableViewController {
    func errorAlert( message: String, title: String = "Alert", completion: (() -> ())? = nil) {
        globalErrorAlert(self, message: message, title: title, completion: completion)
    }
}