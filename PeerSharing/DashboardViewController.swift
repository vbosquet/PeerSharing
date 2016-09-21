//
//  DashboardViewController.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 10/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import Alamofire

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    let directionsApiKey = "AIzaSyCtYpv-xdrnmDb4fCtlCP0mBbAgH3bPEws"
    let locationManager = CLLocationManager()
    
    @IBAction func pickPlace(sender: UIBarButtonItem) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
            
        } else if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignOutSegue" {
            try! FIRAuth.auth()?.signOut()
        } else if segue.identifier == "LoginToChat" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ChatViewController
            
            if let user = user {
                controller.senderId = user.uid
                controller.senderDisplayName = user.displayName
                
            }
        } else if segue.identifier == "SearchNewObjectSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! SearchNewObjectTableViewController
            controller.delegate = self
        }
    }
    
    func addMarker(location: CLLocation, title: String, snippet: String) {
        let position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let marker = GMSMarker(position: position)
        
        marker.title = title
        marker.snippet = snippet
        marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        marker.map = mapView
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        presentViewController(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
}

extension DashboardViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        self.performSegueWithIdentifier("LoginToChat", sender: nil)
    }
}

extension DashboardViewController: SearchNewObjectTableViewControllerDelegate {
    
    func searchNewObjectToLend(controller: SearchNewObjectTableViewController, didSelectTaggersNames taggersList: [String]) {
        searchNewObject(taggersList)
    }
}

extension DashboardViewController {
    
    func searchNewObject(taggersList: [String]) {
        
        self.mapView.clear()
        
        for i in 0..<taggersList.count {
            self.ref.child("addressLocation").child(taggersList[i]).observeEventType(.Value, withBlock: { snapshot in
                
                if snapshot.value!["latitude"] is NSNull && snapshot.value!["longitude"] is NSNull {
                    print("No infos available")
                    
                } else {
                    
                    let latitude = snapshot.value!["latitude"] as! Double
                    let longitude = snapshot.value!["longitude"] as! Double
                    let name = snapshot.value!["firstName"] as! String
                    
                    if let myLocation = self.mapView.myLocation {
                        var urlString = String(format: "https://maps.googleapis.com/maps/api/directions/json?origin=\(myLocation.coordinate.latitude),\(myLocation.coordinate.longitude)&destination=\(latitude),\(longitude)&mode=walking&key=\(self.directionsApiKey)")
                        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        let newLocation = CLLocation(latitude: latitude, longitude: longitude)
                        self.httpRequest(urlString, location: newLocation, title: "Contact \(name)")
                    }
                }
            })
        }
    }
    
    func httpRequest(url: String, location: CLLocation, title: String) {
        Alamofire.request(.GET, url, parameters: nil).responseJSON(completionHandler: { (response) in
            
            if response.result.isFailure == true {
                return
            }
            
            if let JSON = response.result.value {
                
                let data = JSON as! NSDictionary
                let routes = data["routes"]
                
                if let routes = routes where routes.count > 0 {
                    let legs = routes[0]["legs"]
                    
                    if let legs = legs where legs!.count > 0 {
                        let duration = legs![0]["duration"]
                        
                        if let duration = duration {
                            let durationText = duration!["text"]
                            let durationString = "\(durationText as! String) from your current position"
                            
                            self.addMarker(location, title: title, snippet: durationString)
                        }
                    }
                }
            }
        })
    }
}
