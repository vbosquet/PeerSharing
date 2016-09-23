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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var myObjectsToLend = [String]()
    var objectsToLendFromCoreData = [NSManagedObject]()
    var userAuthenticated = FIRAuth.auth()?.currentUser
    var valueObserverHandle:UInt?
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = userAuthenticated {
            self.userId = user.uid
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Retrieve data from DataStore.sqlite
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "ObjectToLend")
        
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
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
    
    func saveObjectToLendToCoreData(name: String) {
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "ObjectToLend")
        
        fetchRequest.predicate = NSPredicate(format: "userId == %@ AND name == %@", userId, name)
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            if result.count == 0 {
                let entity = NSEntityDescription.entityForName("ObjectToLend", inManagedObjectContext: managedContext)
                let objectToLend = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                objectToLend.setValue(name, forKey: "name")
                objectToLend.setValue(userId, forKey: "userId")
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save \(error), \(error.userInfo)")
                }
            
            }
        } catch {
            print("Could not fetch data because of: \(error)")
        }
    }
    
    func selectObjectToLend(picker: ChoosingObjectsToLendTableViewController, didSelectObject objectName: [String]) {
        
        //Save data into DataStore.sqlite
        for i in 0..<objectName.count {
            saveObjectToLendToCoreData(objectName[i])
        }
        
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
        
        //Delete data from Firebase Database
        if let user = userAuthenticated {
            let tagToDeleteRef = ref.child("users").child(user.uid).child("tags").child(objectToDelete)
            tagToDeleteRef.removeValue()
            
            let taggerToDeleteRef = ref.child("objectsToLend").child(objectToDelete).child("taggers").child(user.uid)
            taggerToDeleteRef.removeValue()
        }
        
        //Delete data from DataStore.sqlite
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "ObjectToLend")
        
        fetchRequest.predicate = NSPredicate(format: "userId == %@ AND name == %@", userId, objectToDelete)
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            managedContext.deleteObject(result[0] as! NSManagedObject)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete data because of: \(error)")
            }
            
        } catch {
            print("Could not fetch data because of: \(error)")
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
