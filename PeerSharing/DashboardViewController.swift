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
    
    var taggersList = [String]()
    
    @IBAction func pickPlace(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "What are you looking for?", message: "Enter an object", preferredStyle: .Alert)
        
        let sendAction = UIAlertAction(title: "Send", style: .Default) { (action: UIAlertAction) -> Void in
            let textField = alert.textFields![0]
            print(textField.text!)
            
            self.ref.child("objectsToLend").child("\(textField.text!)").child("taggers").observeEventType(.Value, withBlock: { snapshot in
                let taggers = snapshot.value
                if taggers is NSNull {
                    print("Nobody has this object")
                } else if taggers is NSDictionary {
                    for key in taggers!.keyEnumerator() {
                        if key as? String != self.user?.uid {
                            self.taggersList.append("\(key)")
                        }
                    }
                
                    for i in 0..<self.taggersList.count {
                        self.ref.child("addressLocation").child(self.taggersList[i]).observeEventType(.Value, withBlock: { snapshot in
                            
                            let latitude = snapshot.value!["latitude"] as! Double
                            let longitude = snapshot.value!["longitude"] as! Double
                            let name = snapshot.value!["firstName"] as! String
                            
                            let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let marker = GMSMarker(position: position)
                            
                            self.mapView.camera = GMSCameraPosition(target: position, zoom: 15, bearing: 0, viewingAngle: 0)
                            marker.title = "Contact \(name)"
                            marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
                            marker.map = self.mapView
                        })
                    }
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
        }
        
        alert.addAction(sendAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
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