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
    var location: CLLocation?
    var origin = ""
    
    @IBAction func pickPlace(sender: UIBarButtonItem) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = user {
            ref.child("users").child(user.uid).observeEventType(.Value, withBlock: { (snapshot) in
                let address = snapshot.value!["address"] as! String
                let postalCode = snapshot.value!["postalCode"] as! String
                let city = snapshot.value!["city"] as! String
                
                self.origin = address + ", " + postalCode + ", " + city
            })
        }
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
    
    func updateMapView(location: CLLocation, title: String, snippet: String) {
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        let position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
    }
}

extension DashboardViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        location = newLocation
        
        if let location = location {
            self.updateMapView(location, title: "Your current position", snippet: "")
            self.locationManager.stopUpdatingLocation()
        }
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
                    
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    let title = "Contact \(name)"
                    
                    //self.updateMapView(location, title: "Contact \(name)")
                    self.displayTravelTime(taggersList, location: location, title: title)
                    
                }
            })
        }
    }
    
    func displayTravelTime(taggersList: [String], location: CLLocation, title: String) {
        for i in 0..<taggersList.count {
            self.ref.child("users").child(taggersList[i]).observeEventType(.Value, withBlock: { (snapshot) in
                let address = snapshot.value!["address"] as! String
                let postalCode = snapshot.value!["postalCode"] as! String
                let city = snapshot.value!["city"] as! String
                
                let destination = address + ", " + postalCode + ", " + city
                
                var urlString = String(format: "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.origin)&destination=\(destination)&key=\(self.directionsApiKey)")
                urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                self.httpRequest(urlString, location: location, title: title)
            })
        }
    }
    
    func httpRequest(url: String, location: CLLocation, title: String) {
        Alamofire.request(.GET, url, parameters: nil).responseJSON(completionHandler: { (response) in
            if let JSON = response.result.value {
                let data = JSON as! NSDictionary
                let routes = data["routes"]
                
                if routes != nil {
                    let legs = routes![0]["legs"]
                    
                    if legs != nil {
                        let duration = legs!![0]["duration"]
                        
                        if duration != nil {
                            let durationText = duration!!["text"]
                            let durationString = "\(durationText as! String) from your home"
                            
                            self.updateMapView(location, title: title, snippet: durationString)
                        }
                    }
                    
                }
            }
        })
    }
}
