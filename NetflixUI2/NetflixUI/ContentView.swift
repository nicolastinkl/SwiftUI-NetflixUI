//
//  ContentView.swift
//  NetflixUI
//
//  Created by Balaji Venkatesh on 11/04/24.
//

import SwiftUI

struct ContentView: View {
    var appData: AppData = .init()
    var body: some View {
        ZStack {
            /// First View After Splash Screen
            MainView()
            
            if appData.hideMainView {
                Rectangle()
                    .fill(.black)
                    .ignoresSafeArea()
            }
            
            ZStack {
                if appData.showProfileView {
                    @Bindable var bindableData = appData
                    ProfileView(
                        animateToCenter: $bindableData.animateToCenter,
                        animateToMainView: $bindableData.animateToMainView,
                        progress: $bindableData.progress
                    )
                }
            }
            .animation(.snappy, value: appData.showProfileView)
            
            if !appData.isSplashFinished {
                SplashScreen()
            }
        }
        .environment(appData)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

/// Netflix Assets: https://brand.netflix.com/en/assets/logos/
/// Netflix Logo Lottie File: https://lottiefiles.com/animations/netflix-logo-animation-uCleZIhE7v
