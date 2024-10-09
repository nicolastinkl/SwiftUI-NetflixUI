//
//  Profile.swift
//  NetflixUI
//
//  Created by Balaji Venkatesh on 12/04/24.
//

import SwiftUI

struct Profile: Identifiable {
    var id: UUID = .init()
    var name: String
    var icon: String
    
    var soruceAnchorID: String {
        return id.uuidString + "SOURCE"
    }
    
    var destinationAnchorID: String {
        return id.uuidString + "DESTINATION"
    }
}

var mockProfiles: [Profile] = [
    .init(name: "iJustine", icon: "iJustine"),
    .init(name: "Jenaa", icon: "Jenna"),
]
