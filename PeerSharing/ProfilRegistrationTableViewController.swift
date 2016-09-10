//
//  ProfilRegistrationTableViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 10/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase

class ProfilRegistrationTableViewController: UITableViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    
    var userInfo = UserInfo()
    
    @IBAction func saveProfilInfos(sender: AnyObject) {
        print("Infos saved")
    
    }
    
    @IBAction func cancelRegistration(sender: AnyObject) {
        let user = FIRAuth.auth()?.currentUser
        
        user?.deleteWithCompletion { error in
            if let error = error {
                print("Impossible to delete this user because of error: \(error)")
            } else {
                print("User deleted")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
        
    }
    
}


