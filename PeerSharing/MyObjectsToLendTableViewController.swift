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
    var valueObserverHandle:UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayObjectsTolend()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let valueObserverHandle = self.valueObserverHandle {
            if let user = userAuthenticated {
                self.ref.child("users").child(user.uid).child("objectsToLend").removeObserverWithHandle(valueObserverHandle)
            }
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
        
        if let user = userAuthenticated {
            let objectsListToUpdateRef = self.ref.child("users").child(user.uid)
            objectsListToUpdateRef.updateChildValues(["objectsToLend": self.myObjectsToLend])
        }
        
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
        
        if let user = userAuthenticated {
            let objectToDeleteRef = ref.child("users").child(user.uid).child("objectsToLend").child("\(indexPath.row)")
            objectToDeleteRef.removeValue()
            
        }
    }
    
    func displayObjectsTolend() {
        if let user = userAuthenticated {
            self.valueObserverHandle = self.ref.child("users").child(user.uid).child("objectsToLend").observeEventType(.Value, withBlock:  { snapshot in
                let objectsToDisplay = snapshot.value
                
                if objectsToDisplay is NSNull {
                    print("ObjectsToDisplay is of type NSNull")
                } else if objectsToDisplay is NSArray {
                    print(objectsToDisplay)
                    self.myObjectsToLend = [String]()
                    for object in objectsToDisplay as! NSArray {
                        if let object = object as? String {
                            self.myObjectsToLend.append(object)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        }
        
    }
    
}
