//
//  ChoosingObjectsToLendTableViewController.swift
//  PeerSharing
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit

class ChoosingObjectsToLendTableViewController: UITableViewController {
    
    let objectsToSelect = [
        "Pompe à vélo",
        "Mixer",
        "Balance de cuisine",
        "Forme à gâteau",
        "Four à raclette",
        "Cuiseur de riz",
        "Set à fondue",
        "Fer à gaufre",
        "Machine à pâtes",
        "Wok",
        "Grill",
        "Outils",
        "Perceuse",
        "Ping pong",
        "Trépied",
        "Boule disco",
        "Jeux pour enfant",
        "Cerf volant",
        "Tente",
        "Livres",
        "Journeaux",
        "Scie sauteuse",
        "Machine à coudre",
        "Fer à repasser",
        "Echelle",
        "Rallonge électrique",
        "Table de fête",
        "Outils de jardin",
        "Tondeuse à gazon",
        "Vélo",
        "Remorque à vélo",
        "Carton à bananes",
        "Costumes",
        "Bâteau pneumatique",
        "Accès internet"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return objectsToSelect.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ObjectToSelect", forIndexPath: indexPath)
        cell.textLabel!.text = objectsToSelect[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
    }
    
    
    @IBAction func cancelDidTouch(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
