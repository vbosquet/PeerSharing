//
//  MyObjectsToLendTableViewController.swift
//  PeerSharing
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class MyObjectsToLendTableViewController: UITableViewController, ChoosingObjectsToLendTableViewControllerDelegate {
    
    let ref = FIRDatabase.database().reference()
    var myObjectsToLend = [String]()
    var objectsToLendFromCoreData = [NSManagedObject]()
    var userAuthenticated = FIRAuth.auth()?.currentUser
    var valueObserverHandle:UInt?
    var userFirstName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Retrieve data from DataStore.sqlite
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "ObjectToLend")
        
        if let user = userAuthenticated {
            self.userFirstName = user.displayName!
        }
        
        fetchRequest.predicate = NSPredicate(format: "userFirstName == %@", userFirstName)
        
        var objectNameList = [String]()
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            
            for i in 0..<result.count {
                let objectName = result[i] as! NSManagedObject
                objectsToLendFromCoreData.append(objectName)
                objectNameList.append(objectName.valueForKey("name") as! String)
            }
            
        } catch {
            print("Could not fetch data because of: \(error)")
        }
        
        //let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        //print(paths[0])
        
        myObjectsToLend = objectNameList
        tableView.reloadData()
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
        
        if let user = userAuthenticated {
            let nameUserRef = self.ref.child("addressLocation").child(user.uid).child("firstName")
            nameUserRef.setValue(user.displayName)
        }
        
       
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
        let objectToRemoveFromCoreData = objectsToLendFromCoreData[indexPath.row]
        
        //Delete data from Firebase Database
        if let user = userAuthenticated {
            let tagToDeleteRef = ref.child("users").child(user.uid).child("tags").child(objectToDelete)
            tagToDeleteRef.removeValue()
            
            let taggerToDeleteRef = ref.child("objectsToLend").child(objectToDelete).child("taggers").child(user.uid)
            taggerToDeleteRef.removeValue()
        }
        
        //Delete data from DataStore.sqlite
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        managedContext.deleteObject(objectToRemoveFromCoreData)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete data because of: \(error)")
        }
        
        //Update table view
        myObjectsToLend.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
    }
    
    //Retrieve Data from Firebase Database
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
