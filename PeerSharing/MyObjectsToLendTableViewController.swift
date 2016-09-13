//
//  MyObjectsToLendTableViewController.swift
//  PeerSharing
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase

class MyObjectsToLendTableViewController: UITableViewController, ChoosingObjectsToLendTableViewControllerDelegate {
    
    let ref = FIRDatabase.database().reference()
    var myObjectsToLend = [String]()
    var userAuthenticated: FIRUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.userAuthenticated = user
                
                self.ref.child("users").child(user.uid).child("objectsToLend").observeEventType(.Value, withBlock:  { snapchot in
                    if let objectsListToDiplay = snapchot.value {
                        self.myObjectsToLend = objectsListToDiplay as! [String]
                        self.tableView.reloadData()
                    }
                })
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = userAuthenticated {
            let objectsListToUpdateRef = self.ref.child("users").child(user.uid)
            objectsListToUpdateRef.updateChildValues(["objectsToLend": self.myObjectsToLend])
        }
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myObjectsToLend.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyObjectsToLend", forIndexPath: indexPath)
        let objectName = myObjectsToLend[indexPath.row]
        cell.textLabel!.text = objectName
        
        return cell
    }
    
    @IBAction func cancelDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addingObjectDidTouch(sender: AnyObject) {
    }
    
    func selectObjectToLend(picker: ChoosingObjectsToLendTableViewController, didSelectObject objectName: [String]) {
        myObjectsToLend += objectName
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddObjectToLend" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ChoosingObjectsToLendTableViewController
            controller.delegate = self
            
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        myObjectsToLend.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
    }
    
}
