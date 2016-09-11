//
//  Functions.swift
//  PeerSharing
//
//  Created by Sabrina Jöhl on 11/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import Foundation
import Firebase

func retrieveDataFromProviderData(user: FIRUser) -> String {
    
    var emailAddress = ""
    
    for profile in user.providerData {
        emailAddress = profile.email!
    }
    
    return emailAddress
}