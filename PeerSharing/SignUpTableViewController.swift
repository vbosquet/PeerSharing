//
//  ProfilRegistrationTableViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 10/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase

class SignUpTableViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let ref = FIRDatabase.database().reference()
    let geoCoder = CLGeocoder()
    
    @IBAction func saveProfilInfos(sender: AnyObject) {
        
        if emailTextField.text == "" || passwordTextField.text == "" || firstNameTextField.text  == "" || lastNameTextField.text == "" || addressTextField.text == "" || postalCodeTextField.text == "" || cityTextField.text == "" {
            displayAlert("Please fill in all required fields.")
        }
        
        if addressTextField.text?.characters.count > 0 && postalCodeTextField.text?.characters.count > 0 && cityTextField.text?.characters.count > 0 {
            let newLocation = self.addressTextField.text! + ", " + self.postalCodeTextField.text! + " " + self.cityTextField.text!
            self.geoCoder.geocodeAddressString(newLocation, completionHandler: { (placemarks, error) in
                if error != nil {
                    self.displayAlert("Your address is incorrect.")
                }
            })
        }
        
        FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if error == nil {
                FIRAuth.auth()?.signInWithEmail(self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
                    
                })
            } else {
                
                switch error!.code {
                case FIRAuthErrorCode.ErrorCodeEmailAlreadyInUse.rawValue:
                    self.displayAlert("This email already exists.")
                case FIRAuthErrorCode.ErrorCodeWeakPassword.rawValue:
                    self.displayAlert("Your password is not valid.\nIt must contain at least 6 characters.")
                case FIRAuthErrorCode.ErrorCodeInvalidEmail.rawValue:
                    self.displayAlert("Your email is not valid.")
                default:
                    self.displayAlert("Enter a valid email and password.")
                }
            }
        })
        
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error Entry", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelRegistration(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if let user = user {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = self.firstNameTextField.text!
                changeRequest.commitChangesWithCompletion({ (error) in
                    if let error = error {
                        print("Can not update user's profile because of error: \(error)")
                    } else {
                        print("Profile updated")
                    }
                })
                
                
                let newUser = User(firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, address: self.addressTextField.text!, postalCode: self.postalCodeTextField.text!, city: self.cityTextField.text!)
                let newUserRef = self.ref.child("users").child(user.uid)
                newUserRef.setValue(newUser.toAnyObject())
                
                let newLocation = self.addressTextField.text! + ", " + self.postalCodeTextField.text! + " " + self.cityTextField.text!
                self.getCoordonateFromAddress(newLocation, user: user)
                
                self.performSegueWithIdentifier("SignInSegue", sender: nil)
            }
        })
    }
    
    func getCoordonateFromAddress(location: String, user: FIRUser) {
        self.geoCoder.geocodeAddressString(location, completionHandler: { (placemarks, error) in
            if error == nil, let p = placemarks where !p.isEmpty {
                let mark = CLPlacemark(placemark: placemarks![0])
                let latitude = mark.location?.coordinate.latitude
                let longitude = mark.location?.coordinate.longitude
                
                let newLatitudeRef = self.ref.child("addressLocation").child(user.uid).child("latitude")
                newLatitudeRef.setValue(latitude)
                
                let newLongitudeRef = self.ref.child("addressLocation").child(user.uid).child("longitude")
                newLongitudeRef.setValue(longitude)
            } else {
                print("Address incorrect")
            }
        })
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


