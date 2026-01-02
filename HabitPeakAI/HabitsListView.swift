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
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.indigo.opacity(0.3), .blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                List {
                    ForEach(habits) { habit in
                        HabitRowView(habit: habit, modelContext: modelContext)
                    }
                    .onDelete(perform: deleteHabits)
                }
                .navigationTitle("Today's Habits (\(habits.count))")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
    
    private func deleteHabits(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(habits[index])
            }
        }
    }
}

struct HabitRowView: View {
    let habit: Habit
    let modelContext: ModelContext
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Image(systemName: categoryIcon(for: habit.category))
                .font(.title2)
                .foregroundStyle(categoryColor(for: habit.category))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(habit.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Streak Badge
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                Text("\(habit.streak)")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.orange.opacity(0.2))
            .foregroundStyle(.orange)
            .clipShape(Capsule())
            
            // COMPLETE Button
            Button(action: {
                completeHabit()
            }) {
                Image(systemName: habit.lastCompleted != nil ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.lastCompleted != nil ? .green : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func completeHabit() {
        habit.streak += 1
        habit.lastCompleted = Date()
        try? modelContext.save()
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Longevity": return "leaf.fill"
        case "Mental Health": return "brain.head.profile"
        case "Mindfulness": return "figure.mind.and.body"
        case "Career": return "chart.line.uptrend.xyaxis"
        case "Relationships": return "heart.circle.fill"
        case "Parenting": return "person.2.fill"
        case "Fitness": return "dumbbell"
        case "Self Love": return "figure.and.heart"
        default: return "circle"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Longevity": return .green
        case "Mental Health": return .blue
        case "Mindfulness": return .purple
        case "Career": return .orange
        case "Relationships": return .pink
        case "Parenting": return .teal
        case "Fitness": return .red
        case "Self Love": return .indigo
        default: return .gray
        }
    }
}

#Preview {
    HabitsListView()
        .modelContainer(for: Habit.self)
}
