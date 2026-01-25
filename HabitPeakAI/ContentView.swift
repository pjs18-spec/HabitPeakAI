//
//  ContentView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-08.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DailySignalView()
                .tabItem {
                    Label("Signals", systemImage: "chart.bar")
                }
            
            HabitTrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "calendar")
                }
            
            Text("Trends Coming Soon")
                .tabItem {
                    Label("Trends", systemImage: "arrow.up.right")
                }
        }
    }
}

#Preview {
    ContentView()
}
