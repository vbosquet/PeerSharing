//
//  ProfilRegistrationTableViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 10/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit

class ProfilRegistrationTableViewController: UITableViewController {
    
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    var userInfo = UserInfo()
    
    
    
    @IBAction func saveProfilInfos(sender: AnyObject) {
        /*userInfo.firstName = firstNameTextField.text!
        userInfo.lastName = lastNameTextField.text!
        userInfo.address = addressTextField.text!
        userInfo.postalCode = postalCodeTextField.text!
        userInfo.city = cityTextField.text!*/
        
        print("Infos saved")
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DisplayDashboard" {
            let navivationController = segue.destinationViewController as! UINavigationController
            _ = navivationController.topViewController as! DashboardViewController
        }
    }
    
}


