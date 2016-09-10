//
//  ViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 09/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase

class AuthViewController: UIViewController {

    @IBOutlet weak var emailAddressLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    var segueShouldOccur = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func createAccount(sender: AnyObject) {
        FIRAuth.auth()?.createUserWithEmail(emailAddressLabel.text!, password: passwordLabel.text!) { (user, error) in
            if error != nil {
                print("Incorrect")
                self.segueShouldOccur = false
                
            } else {
                print("User created")
            }
        }
    }
    
    
    @IBAction func signIn(sender: AnyObject) {
        FIRAuth.auth()?.signInWithEmail(emailAddressLabel.text!, password: passwordLabel.text!) { (user, error) in
            if error != nil {
                print("Incorrect")
                self.segueShouldOccur = false
                
            } else {
                print("Correct")
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "AddProfil" {
            if !segueShouldOccur {
                print("Segue won't occur")
                segueShouldOccur = true
                return false
            } else {
                print("Segue will occur")
            }
        } else if identifier == "DisplayDashboard" {
            if !segueShouldOccur {
                print("Segue won't occur")
                segueShouldOccur = true
                return false
            } else {
                print("Segue will occur")
            }
        }
        
        return true
        
    }
}

