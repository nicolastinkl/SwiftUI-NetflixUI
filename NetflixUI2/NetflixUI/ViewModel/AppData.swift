//
//  AppData.swift
//  NetflixUI
//
//  Created by Balaji Venkatesh on 11/04/24.
//

import SwiftUI

@Observable
class AppData {
    var isSplashFinished: Bool = false
    var activeTab: Tab = .home
    var hideMainView: Bool = false
    /// Profile Selection Properties
    var showProfileView: Bool = false
    var tabProfileRect: CGRect = .zero
    var watchingProfile: Profile?
    var animateProfile: Bool = false
    var fromTabBar: Bool = false
    /// Profile Animation Properties
    var animateToCenter: Bool = false
    var animateToMainView: Bool = false
    var progress: CGFloat = 0
    
    func resetProfileAnimation() {
        animateToCenter = false
        animateToMainView = false
        progress = 0
    }
}
