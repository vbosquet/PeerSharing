//
//  ViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 09/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.performSegueWithIdentifier("LoginSegue", sender: nil)
            }
        })
        
    }
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        if emailAddressTextField.text == "" || passwordTextField.text == "" {
            displayAlert("Please, enter your email and password.")
        } else {
            FIRAuth.auth()?.signInWithEmail(emailAddressTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    switch error!.code {
                    case FIRAuthErrorCode.ErrorCodeWrongPassword.rawValue:
                        self.displayAlert("Your password is incorrect.")
                    case FIRAuthErrorCode.ErrorCodeUserDisabled.rawValue:
                        self.displayAlert("Your account is disabled.")
                    default:
                        self.displayAlert("Your account does not exist.")
                    }
                }
            })
        }
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error Entry", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func signUpDidTouch(sender: AnyObject) {
    
    }
    
    @IBAction func signOutDidTouch(segue: UIStoryboardSegue) {
    }
    
    
    
}

