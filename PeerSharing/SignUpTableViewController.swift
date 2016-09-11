//
//  ProfilRegistrationTableViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 10/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase

class SignUpTableViewController: UITableViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    let ref = FIRDatabase.database().reference()
    
    @IBAction func saveProfilInfos(sender: AnyObject) {
        
        let newUser = User(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, address: addressTextField.text!, postalCode: postalCodeTextField.text!, city: cityTextField.text!)
        let newUserRef = ref.child(firstNameTextField.text!.lowercaseString)
        newUserRef.setValue(newUser.toAnyObject())
        
        FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if error == nil {
                FIRAuth.auth()?.signInWithEmail(self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
                    
                })
            }
        })
        
        print("User created")
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func cancelRegistration(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
        
    }
    
}


