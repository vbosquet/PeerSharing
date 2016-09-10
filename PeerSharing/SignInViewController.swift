//
//  ViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 09/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailAddressLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    
    var logSucess = false
    
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
                self.login()
                
            } else {
                print("User created")
                self.login()
            }
        }
    }
    
    
    @IBAction func signIn(sender: AnyObject) {
        login()
        
    }
    
    func login() {
        FIRAuth.auth()?.signInWithEmail(emailAddressLabel.text!, password: passwordLabel.text!) { (user, error) in
            if error != nil {
                print("Incorrect")
                
            } else {
                print("Correct")
                self.logSucess = true
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if logSucess {
            logSucess = false
            return true
        } else {
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddProfil" {
            let navivationController = segue.destinationViewController as! UINavigationController
            _ = navivationController.topViewController as! ProfilRegistrationTableViewController
        }
    }
}

