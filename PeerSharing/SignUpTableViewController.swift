//
//  ProfilRegistrationTableViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 10/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class SignUpTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameField: SkyFloatingLabelTextField!
    @IBOutlet weak var addressField: SkyFloatingLabelTextField!
    @IBOutlet weak var postalCodeField: SkyFloatingLabelTextField!
    @IBOutlet weak var cityField: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameField: SkyFloatingLabelTextField!
    
    let ref = FIRDatabase.database().reference()
    let geoCoder = CLGeocoder()
    let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
    
    @IBAction func saveProfilInfos(sender: AnyObject) {
        
        if emailField.text == "" || passwordField.text == "" || firstNameField.text  == "" || lastNameField.text == "" || addressField.text == "" || postalCodeField.text == "" || cityField.text == "" {
            
            displayAlert("Please fill in all required fields.")
            
            if emailField.text?.characters.count > 0 {
                emailField.lineColor = lightGreyColor
            } else {
                emailField.lineColor = UIColor.redColor()
            }
            
            if passwordField.text?.characters.count > 0 {
                passwordField.lineColor = lightGreyColor
            } else {
                passwordField.lineColor = UIColor.redColor()
            }
            
            if firstNameField.text?.characters.count > 0 {
                firstNameField.lineColor = lightGreyColor
            } else {
                firstNameField.lineColor = UIColor.redColor()
            }
            
            if lastNameField.text?.characters.count > 0 {
                lastNameField.lineColor = lightGreyColor
            } else {
                lastNameField.lineColor = UIColor.redColor()
            }
            
            if addressField.text?.characters.count > 0 {
                addressField.lineColor = lightGreyColor
            } else {
                addressField.lineColor = UIColor.redColor()
            }
            
            if postalCodeField.text?.characters.count > 0 {
                postalCodeField.lineColor = lightGreyColor
            } else {
                postalCodeField.lineColor = UIColor.redColor()
            }
            
            if cityField.text?.characters.count > 0 {
                cityField.lineColor = lightGreyColor
            } else {
                cityField.lineColor = UIColor.redColor()
            }
            
        } else {
            
            let newLocation = self.addressField.text! + ", " + self.postalCodeField.text! + " " + self.cityField.text!
            
            self.geoCoder.geocodeAddressString(newLocation, completionHandler: { (placemarks, error) in
                if error != nil {
                    self.displayAlert("Your address is incorrect.")
                    
                    self.addressField.lineColor = UIColor.redColor()
                    self.postalCodeField.lineColor = UIColor.redColor()
                    self.cityField.lineColor = UIColor.redColor()
                    
                } else {
                    
                    FIRAuth.auth()?.createUserWithEmail(self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                        if error == nil {
                            FIRAuth.auth()?.signInWithEmail(self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                                
                            })
                            
                        } else {
                            
                            switch error!.code {
                            case FIRAuthErrorCode.ErrorCodeEmailAlreadyInUse.rawValue:
                                self.displayAlert("This email already exists.")
                                self.emailField.lineColor = UIColor.redColor()
                            case FIRAuthErrorCode.ErrorCodeWeakPassword.rawValue:
                                self.displayAlert("Your password is not valid.\nIt must contain at least 6 characters.")
                                self.passwordField.lineColor = UIColor.redColor()
                            case FIRAuthErrorCode.ErrorCodeInvalidEmail.rawValue:
                                self.displayAlert("Your email is not valid.")
                                self.emailField.lineColor = UIColor.redColor()
                            default:
                                self.displayAlert("Enter a valid email and password.")
                                self.emailField.lineColor = UIColor.redColor()
                                self.passwordField.lineColor = UIColor.redColor()
                            }
                        }
                    })
                    
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
    
    @IBAction func cancelRegistration(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if let user = user {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = self.firstNameField.text!
                changeRequest.commitChangesWithCompletion({ (error) in
                    if let error = error {
                        print("Can not update user's profile because of error: \(error)")
                    } else {
                        print("Profile updated")
                    }
                })
                
                
                let address = self.addressField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let postaclCode = self.postalCodeField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let city = self.cityField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                let newUser = User(firstName: self.firstNameField.text!, lastName: self.lastNameField.text!, address: address, postalCode: postaclCode, city: city)
                let newUserRef = self.ref.child("users").child(user.uid)
                newUserRef.setValue(newUser.toAnyObject())
                
                let newLocation = self.addressField.text! + ", " + self.postalCodeField.text! + " " + self.cityField.text!
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
        
        emailField.delegate = self
        passwordField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        addressField.delegate = self
        postalCodeField.delegate = self
        cityField.delegate = self
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == emailField || textField == passwordField || textField == firstNameField || textField == lastNameField || textField == addressField || textField == postalCodeField || textField == cityField {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                floatingLabelTextField.lineColor = lightGreyColor
            }
        }
    }
}


