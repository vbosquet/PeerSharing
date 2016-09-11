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
        FIRAuth.auth()?.signInWithEmail(emailAddressTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            
        })
        
    }
    
    
    @IBAction func signUpDidTouch(sender: AnyObject) {
        
    
    }
    
}

