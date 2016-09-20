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
import GooglePlacePicker

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var placemark: CLPlacemark?
    
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
    
    func updateMapView(location: CLLocation) {
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        let position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = "Your current position"
        marker.map = mapView
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line1 = ""
        
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        return line1
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
            self.updateMapView(location)
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
        
        for i in 0..<taggersList.count {
            self.ref.child("addressLocation").child(taggersList[i]).observeEventType(.Value, withBlock: { snapshot in
                
                if snapshot.value!["latitude"] is NSNull && snapshot.value!["longitude"] is NSNull {
                    print("No infos available")
                    
                } else {
                    
                    let latitude = snapshot.value!["latitude"] as! Double
                    let longitude = snapshot.value!["longitude"] as! Double
                    let name = snapshot.value!["firstName"] as! String
                    
                    let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let marker = GMSMarker(position: position)
                    
                    self.mapView.camera = GMSCameraPosition(target: position, zoom: 15, bearing: 0, viewingAngle: 0)
                    marker.title = "Contact \(name)"
                    marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
                    marker.map = self.mapView
                    
                }
            })
        }
    }
}
