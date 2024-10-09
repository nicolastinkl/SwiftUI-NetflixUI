//
//  ProfileView.swift
//  NetflixUI
//
//  Created by Balaji Venkatesh on 12/04/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppData.self) private var appData
    /// View Properties
    @Binding var animateToCenter: Bool
    @Binding var animateToMainView: Bool
    @Binding var progress: CGFloat
    var body: some View {
        VStack {
            Button("Edit") {
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .overlay {
                Text("Who's Watching?")
                    .font(.title3.bold())
            }
            .overlay(alignment: .leading) {
                if appData.fromTabBar {
                    Button(action: {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                            appData.showProfileView = false
                            appData.hideMainView = false
                            appData.fromTabBar = false
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .contentShape(.rect)
                    })
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(100), spacing: 25), count: 2)) {
                ForEach(mockProfiles) { profile in
                    ProfileCardView(profile)
                }
                
                /// Add Button
                Button(action: {}, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.white.opacity(0.8), lineWidth: 0.8)
                        
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 100, height: 100)
                    .contentShape(.rect)
                })
            }
            .frame(maxHeight: .infinity)
        }
        .padding(15)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(animateToCenter ? 0 : 1)
        .background(.black)
        .opacity(animateToMainView ? 0 : 1)
        .overlayPreferenceValue(RectAnchorKey.self) { value in
            AnimationLayerView(value)
        }
    }
    
    /// Profile Animation View
    @ViewBuilder
    func AnimationLayerView(_ value: [String: Anchor<CGRect>]) -> some View {
        GeometryReader { proxy in
            if let profile = appData.watchingProfile, let sourceAnchor = value[profile.soruceAnchorID], appData.animateProfile, appData.tabProfileRect != .zero {
                let sRect = proxy[sourceAnchor]
                let screenRect = proxy.frame(in: .global)
                /// Positions
                let sourcePosition = CGPoint(x: sRect.midX, y: sRect.midY)
                let centerPosition = CGPoint(x: screenRect.width / 2, y: (screenRect.height / 2) - 40)
                let destinationPosition = CGPoint(x: appData.tabProfileRect.midX, y: appData.tabProfileRect.midY)
                
                let animationPath = Path { path in
                    path.move(to: centerPosition)
                    path.addQuadCurve(to: destinationPosition, control: CGPoint(x: centerPosition.x * 2, y: centerPosition.y - (centerPosition.y / 0.8)))
                }
                
                /// To visuvalize Animation Path
                //animationPath.stroke(.white.opacity(0.5), lineWidth: 1)
                
                let endPosition = animationPath.trimmedPath(from: 0, to: 1).currentPoint ?? destinationPosition
                let currentPosition = animationPath.trimmedPath(from: 0, to: 0.97).currentPoint ?? destinationPosition
                
                let diff = CGSize(width: endPosition.x - currentPosition.x, height: endPosition.y - currentPosition.y)
                
                /// Selected Profile Image View With Loading Indicator
                ZStack {
                    Image(profile.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: animateToMainView ? 25 : sRect.width, height: animateToMainView ? 25 : sRect.height)
                        .clipShape(.rect(cornerRadius: animateToMainView ? 4 : 10))
                        .animation(.snappy(duration: 0.3, extraBounce: 0), value: animateToMainView)
                        .opacity(animateToMainView && appData.activeTab != .account ? 0.6 : 1)
                        .modifier(
                            AnimatedPositionModifier(
                                source: sourcePosition,
                                center: centerPosition,
                                destination: destinationPosition,
                                animateToCenter: animateToCenter,
                                animateToMainView: animateToMainView,
                                path: animationPath,
                                progress: progress
                            )
                        )
                        .offset(animateToMainView ? diff : .zero)
                    
                    /// Custom Netflix Style Indicator
                    NetflixLoader()
                        .frame(width: 60, height: 60)
                        .offset(y: 80)
                        .opacity(animateToCenter ? 1 : 0)
                        .opacity(animateToMainView ? 0 : 1)
                }
                .transition(.identity)
                .task {
                    guard !animateToCenter else { return }
                    await animateUser()
                }
            }
        }
    }
    
    func animateUser() async {
        withAnimation(.bouncy(duration: 0.35)) {
            animateToCenter = true
        }
        
        await loadContents()
        
        withAnimation(.snappy(duration: 0.6, extraBounce: 0.1), completionCriteria: .removed) {
            animateToMainView = true
            appData.hideMainView = false
            progress = 0.97
        } completion: {
            appData.showProfileView = false
            appData.animateProfile = false
            appData.fromTabBar = false
        }
    }
    
    /// Load Contents
    func loadContents() async {
        /// Load Any Network Content Here
        try? await Task.sleep(for: .seconds(1))
    }
    
    /// Profile Card View
    @ViewBuilder
    func ProfileCardView(_ profile: Profile) -> some View {
        VStack(spacing: 8) {
            let status = profile.id == appData.watchingProfile?.id
            GeometryReader { _ in
                Image(profile.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 10))
                    .opacity(animateToCenter ? 0 : 1)
            }
            .animation(status ? .none : .bouncy(duration: 0.35), value: animateToCenter)
            .frame(width: 100, height: 100)
            .anchorPreference(key: RectAnchorKey.self, value: .bounds, transform: { anchor in
                return [profile.soruceAnchorID: anchor]
            })
            .onTapGesture {
                appData.watchingProfile = profile
                appData.animateProfile = true
            }
            
            Text(profile.name)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
    }
}

struct AnimatedPositionModifier: ViewModifier, Animatable {
    var source: CGPoint
    var center: CGPoint
    var destination: CGPoint
    var animateToCenter: Bool
    var animateToMainView: Bool
    var path: Path
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .position(
                animateToCenter ? animateToMainView ? (path.trimmedPath(from: 0, to: progress).currentPoint ?? center) : center : source
            )
    }
}

#Preview {
    ContentView()
}
