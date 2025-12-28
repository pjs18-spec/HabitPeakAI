//
//  HabitsListView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2025-12-27.
//

import SwiftUI
import SwiftData

struct HabitsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    
    var body: some View {
        List {
            ForEach(habits) { habit in
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.headline)
                    Text("Streak: \(habit.streak) days")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Today's Habits")
    }
}

#Preview {
    HabitsListView()
        .modelContainer(for: Habit.self)
}

