//
//  UserInfo.swift
//  PeerSharing
//
//  Created by virginie-bosquet on 10/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    var firstName = ""
    var lastName = ""
    var address = ""
    var postalCode = ""
    var city = ""
    var email = ""
    var uid = ""
    
    init(firstName: String, lastName:String, address: String, postalCode: String, city: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.postalCode = postalCode
        self.city = city
    }
    
    init(user: FIRUser) {
        uid = user.uid
        email = retrieveDataFromProviderData(user)
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "address": address,
            "postalCode": postalCode,
            "city": city
        ]
    }}
