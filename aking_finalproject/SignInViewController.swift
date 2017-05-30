//
//  SignInController.swift
//  aking_finalproject
//
//  Created by Allison King on 5/29/17.
//  Copyright © 2017 Allison King. All rights reserved.
//

import Foundation

import UIKit
import Firebase

class SignInViewController : UIViewController {
    
    // Constants
    let loginToClock = "LoginToClock"
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func logInPressed(_ sender: UIButton) {
        let emailField = emailTextField.text!
        let passwordField = passwordTextField.text!
        Auth.auth().signIn(withEmail: emailField, password: passwordField)
    }
/* should refer to this link later:
     https://stackoverflow.com/questions/32151178/how-do-you-include-a-username-when-storing-email-and-password-using-firebase-ba */
    @IBAction func signInPressed(_ sender: UIButton) {
        let emailField = emailTextField.text!
        let passwordField = passwordTextField.text!
        Auth.auth().createUser(withEmail: emailField, password: passwordField) { (user, error) in
            if error == nil {
                Auth.auth().signIn(withEmail: emailField,
                                       password: passwordField)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: self.loginToClock, sender: nil)
            }
        }
    }
}
