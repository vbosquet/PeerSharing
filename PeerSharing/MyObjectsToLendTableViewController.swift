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
    var userAuthenticated = FIRAuth.auth()?.currentUser
    var replacingObjectsToLendField = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayObjectsTolend()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        if replacingObjectsToLendField {
            myObjectsToLend = objectName
            replacingObjectsToLendField = false
            
        } else {
            myObjectsToLend += objectName
        }
        
        
        if let user = userAuthenticated {
            let objectsListToUpdateRef = self.ref.child("users").child(user.uid)
            objectsListToUpdateRef.updateChildValues(["objectsToLend": self.myObjectsToLend])
        }
        
        displayObjectsTolend()
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
    
    func displayObjectsTolend() {
        if let user = userAuthenticated {
            self.ref.child("users").child(user.uid).child("objectsToLend").observeEventType(.Value, withBlock:  { snapchot in
                let objectsListToDiplay = snapchot.value as! [String]
                self.myObjectsToLend = objectsListToDiplay
                
                if self.myObjectsToLend[0] == "null" {
                    self.replacingObjectsToLendField = true
                }
                
                self.tableView.reloadData()
            })
        }
        
    }
    
}
