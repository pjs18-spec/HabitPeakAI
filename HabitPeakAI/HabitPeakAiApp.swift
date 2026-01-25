//
//  DailySignalView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-08.
//

import SwiftUI
import SwiftData

@main
struct HabitPeakAIApp: App {
    
    // Setup SwiftData container for the DailySignal model
    let container: ModelContainer = {
        do {
            return try ModelContainer(for: DailySignal.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container) // inject the model context for the entire app
        }
    }
}



