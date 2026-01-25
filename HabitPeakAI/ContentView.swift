//
//  ContentView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-08.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DailySignalView()
            }
            .tabItem {
                Label("Signals", systemImage: "chart.bar")
            }
            
            NavigationStack {
                HabitTrackerView()
            }
            .tabItem {
                Label("Tracker", systemImage: "calendar")
            }
            
            NavigationStack {
                HistoryTrendView()
            }
            .tabItem {
                Label("Trends", systemImage: "arrow.up.right")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: DailySignal.self)
}
