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
                self.ref.child("users").child(user.uid).child("tags").removeObserverWithHandle(valueObserverHandle)
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
        
        for index in 0..<objectName.count {
            let objectToSaveRef = ref.child("objectsToLend").child("\(objectName[index])")
            objectToSaveRef.updateChildValues(["name": objectName[index]])
        }
        
        if let user = userAuthenticated {
            for index in 0..<objectName.count {
                let taggerToSaveRef = ref.child("objectsToLend").child("\(objectName[index])").child("taggers")
                taggerToSaveRef.updateChildValues([user.uid: "true"])
            }
        }
        
        if let user = userAuthenticated {
            for index in 0..<objectName.count {
                let tagToSaveRef = ref.child("users").child(user.uid).child("tags")
                tagToSaveRef.updateChildValues(["\(objectName[index])": "true"])
            }
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
        let objectToDelete = myObjectsToLend[indexPath.row]
        
        if let user = userAuthenticated {
            let tagToDeleteRef = ref.child("users").child(user.uid).child("tags").child(objectToDelete)
            tagToDeleteRef.removeValue()
            
            let taggerToDeleteRef = ref.child("objectsToLend").child(objectToDelete).child("taggers").child(user.uid)
            taggerToDeleteRef.removeValue()
        }
        
        myObjectsToLend.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
    }
    
    func displayObjectsTolend() {
        
        if let user = userAuthenticated {
            valueObserverHandle = ref.child("users").child(user.uid).child("tags").observeEventType(.Value, withBlock: { snapshot in
                let tags = snapshot.value
                
                if tags is NSNull {
                    print("There is no tag to display")
                } else if tags is NSDictionary {
                    var tagList = [String]()
                    
                    for key in tags!.keyEnumerator() {
                        tagList.append("\(key)")
                    }
                    
                    self.myObjectsToLend = tagList
                    self.tableView.reloadData()
                    
                }
            
            })
        }
        
    }
    
}
