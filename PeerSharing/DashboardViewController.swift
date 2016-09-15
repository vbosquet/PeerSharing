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
    let geoCoder = CLGeocoder()
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    var taggersList = [String]()
    var newLocations = [String]()
    var address = [String]()
    var postalCode = [String]()
    var city = [String]()
    
    @IBAction func pickPlace(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "What are you looking for?", message: "Enter an object", preferredStyle: .Alert)
        
        let sendAction = UIAlertAction(title: "Send", style: .Default) { (action: UIAlertAction) -> Void in
            let textField = alert.textFields![0]
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
                    self.findNewLocations()
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
    
    func findNewLocations() {
        
        for index in taggersList {
            ref.child("users").child(index).observeEventType(.Value, withBlock: { snapshot in
                let userInfos = snapshot.value as! NSDictionary
                
                for (key, value) in userInfos {
                    if key as! String == "address" {
                        self.address.append(value as! String)
                    } else if key as! String == "postalCode" {
                        self.postalCode.append(value as! String)
                    } else if key as! String == "city" {
                        self.city.append(value as! String)
                    }
                }

            })
        }
    }
    
    func getCoordonateFromAddress(location: String) {
        self.geoCoder.geocodeAddressString(location, completionHandler: { (placemarks, error) in
            if error == nil, let p = placemarks where !p.isEmpty {
                let mark = CLPlacemark(placemark: placemarks![0])
                self.displayNewLocation(mark)
                print("latitude: \(mark.location!.coordinate.latitude)")
                print("longitude: \(mark.location!.coordinate.longitude)")
            }
        })
    }
    
    func displayNewLocation(placemark: CLPlacemark) {
        mapView.camera = GMSCameraPosition(target: (placemark.location?.coordinate)!, zoom: 15, bearing: 0, viewingAngle: 0)
        let position = CLLocationCoordinate2D(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = "New location"
        marker.map = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignOutSegue" {
            try! FIRAuth.auth()?.signOut()
        
        }
    }
    
    func updateMapView(location: CLLocation) {
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        let position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = "You are here"
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