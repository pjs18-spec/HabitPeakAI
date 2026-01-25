//
//  MainTabView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-08.
//

import SwiftUI

struct MainTabView: View {
    
    // Keep track of which tab is selected
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - Daily Signals
            DailySignalView()
                .tag(0)
            
            // MARK: - History & Trends
            HistoryTrendView()
                .tag(1)
        }
        .accentColor(Color("AccentPrimary"))
        .onAppear {
            // Optional: Make tab bar background match app's premium style
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "Background")
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // hides any default tab indicators
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
