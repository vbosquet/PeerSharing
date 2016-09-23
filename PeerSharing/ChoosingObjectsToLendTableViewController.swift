//
//  ChoosingObjectsToLendTableViewController.swift
//  PeerSharing
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData

protocol ChoosingObjectsToLendTableViewControllerDelegate: class {
    func selectObjectToLend(picker: ChoosingObjectsToLendTableViewController, didSelectObject objectName: [String])
}

class ChoosingObjectsToLendTableViewController: UITableViewController {

    var objectsToSelect = [ObjectToLend]()
    var objectsSelectedList = [String]()
    weak var delegate: ChoosingObjectsToLendTableViewControllerDelegate?
    
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

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return objectsToSelect.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ObjectToSelect", forIndexPath: indexPath)
        let objectName = objectsToSelect[indexPath.row]
        cell.textLabel!.text = objectName.name
        
        configureChekmarkForCell(cell, indexPath: indexPath)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            let selectedObject = objectsToSelect[indexPath.row]
            
            selectedObject.toggleChecked()
            configureChekmarkForCell(cell, indexPath: indexPath)
            
            if selectedObject.checked {
                objectsSelectedList.append(selectedObject.name)
            } else {
                objectsSelectedList.removeLast()
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    @IBAction func cancelDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveDidTouch(sender: AnyObject) {
        if let delegate = delegate {
            
            delegate.selectObjectToLend(self, didSelectObject: objectsSelectedList)
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode = .CustomView
            let image = UIImage(named: "Checkmark")?.imageWithRenderingMode(.AlwaysTemplate)
            hud.customView = UIImageView(image: image)
            hud.square = true
            hud.label.text = "Save"
            
            afterDelay(0.6) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func configureChekmarkForCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let selectedObject = objectsToSelect[indexPath.row]
        
        if selectedObject.checked {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    
    }
}
