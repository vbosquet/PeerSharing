//
//  SearchNewObjectTableViewController.swift
//  PeerSharing
//
//  Created by Sabrina Jöhl on 20/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import CoreData

protocol SearchNewObjectTableViewControllerDelegate: class {
    func searchNewObjectToLend(controller: SearchNewObjectTableViewController, didSelectTaggersNames taggersList: [String])
}

class SearchNewObjectTableViewController: UITableViewController {
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    var objectsToSelect = [ObjectToLend]()
    var selectedObjectName = ""
    var selectedIndexPath: NSIndexPath?
    weak var delegate: SearchNewObjectTableViewControllerDelegate?
    var taggersList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objectsToSelect.append(ObjectToLend(withName: "Pompe à vélo"))
        objectsToSelect.append(ObjectToLend(withName: "Mixer"))
        objectsToSelect.append(ObjectToLend(withName: "Balance de cuisine"))
        objectsToSelect.append(ObjectToLend(withName: "Forme à gâteau"))
        objectsToSelect.append(ObjectToLend(withName: "Four à raclette"))
        objectsToSelect.append(ObjectToLend(withName: "Cuiseur de riz"))
        objectsToSelect.append(ObjectToLend(withName: "Set à fondue"))
        objectsToSelect.append(ObjectToLend(withName: "Fer à gaufre"))
        objectsToSelect.append(ObjectToLend(withName: "Machine à pâtes"))
        objectsToSelect.append(ObjectToLend(withName: "Wok"))
        objectsToSelect.append(ObjectToLend(withName: "Grill"))
        objectsToSelect.append(ObjectToLend(withName: "Outils"))
        objectsToSelect.append(ObjectToLend(withName: "Perceuse"))
        objectsToSelect.append(ObjectToLend(withName: "Jeux pour enfants"))
        objectsToSelect.append(ObjectToLend(withName: "Cerf volant"))
        objectsToSelect.append(ObjectToLend(withName: "Tente"))
        objectsToSelect.append(ObjectToLend(withName: "Livres"))
        objectsToSelect.append(ObjectToLend(withName: "Scie sauteuse"))
        
        var objectNameList = [String]()
        
        for i in 0..<objectsToSelect.count {
            let objectName = objectsToSelect[i].name
            objectNameList.append(objectName)
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "ObjectToLend")
        
        for i in 0..<objectNameList.count {
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND userId != %@", objectNameList[i], (user?.uid)!)
            
            do {
                let result = try managedContext.executeFetchRequest(fetchRequest)
                objectsToSelect[i].numberOfTaggers = result.count
                
            } catch {
                print("Could not fetch data because of: \(error)")
            }
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedIndexPath()
    }

    @IBAction func cancelButtonDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsToSelect.count
    }
    
    func cellForTableView(tableView: UITableView) -> UITableViewCell {
        let cellIndentifier = "Cell"
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellIndentifier) {
            return cell
        } else {
            return UITableViewCell(style: .Subtitle, reuseIdentifier: cellIndentifier)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = cellForTableView(tableView)
        let objectName = objectsToSelect[indexPath.row]
        let count = objectsToSelect[indexPath.row].numberOfTaggers
        cell.textLabel!.text = objectName.name
        
        if count == 0 {
            cell.detailTextLabel?.text = "(0 tags)"
        } else {
            cell.detailTextLabel?.text = "\(count) tags"
        }
        
        if indexPath == selectedIndexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath != selectedIndexPath {
            let oldSelection = self.selectedIndexPath
            
            self.selectedIndexPath = indexPath
            let objectName = objectsToSelect[indexPath.row]
            selectedObjectName = objectName.name
            
            var toUpdate = [indexPath]
            if let oldSelection = oldSelection {
                toUpdate.insert(oldSelection, atIndex: 0)
            }
            
            tableView.reloadRowsAtIndexPaths(toUpdate, withRowAnimation: .Fade)
            
            self.ref.child("objectsToLend").child("\(selectedObjectName)").child("taggers").observeEventType(.Value, withBlock: { snapshot in
                let taggers = snapshot.value
                if taggers is NSNull {
                   self.displayAlert("Nobody has this object", title: "No Result Found")
                    
                } else if taggers is NSDictionary {
                    for key in taggers!.keyEnumerator() {
                        if key as? String != self.user?.uid {
                            self.taggersList.append("\(key)")
                        }
                    }
                    
                    if self.taggersList.count > 0 {
                        if let delegate = self.delegate {
                            delegate.searchNewObjectToLend(self, didSelectTaggersNames: self.taggersList)
                            
                            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                            hud.mode = .CustomView
                            let image = UIImage(named: "Checkmark")?.imageWithRenderingMode(.AlwaysTemplate)
                            hud.customView = UIImageView(image: image)
                            hud.square = true
                            hud.label.text = "Done"
                            
                            afterDelay(0.6) {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                        
                    } else {
                        self.displayAlert("Nobody has this object", title: "No Result Found")
                    }
                }
            })
            
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func updateSelectedIndexPath() {
        for i in 0..<objectsToSelect.count {
            if objectsToSelect[i].name == selectedObjectName {
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }
    }
    
    func displayAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
}
