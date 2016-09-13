//
//  ObjectToLend.swift
//  PeerSharing
//
//  Created by BT-Training on 13/09/16.
//  Copyright © 2016 virginie. All rights reserved.
//

import Foundation

class ObjectToLend {
    var name = ""
    var checked = false
    
    init(withName: String) {
        name = withName
    }
    
    func toggleChecked() {
        checked = !checked
    }
}
