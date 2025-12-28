//
//  ContentView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2025-12-27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                        
                        Text("HabitPeak AI")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundStyle(.yellow)
                            Text("AI Categories")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            // LONGIVITY - NAVIGATION
                            NavigationLink(destination: LongevityDetailView()) {
                                AIHabitButton(name: "Longevity", category: "Vitality", color: .green)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            AIHabitButton(name: "Mental Health", category: "Mindset", color: .blue)
                            AIHabitButton(name: "Mindfulness", category: "Presence", color: .purple)
                            AIHabitButton(name: "Career", category: "Growth", color: .orange)
                            AIHabitButton(name: "Relationships", category: "Connection", color: .pink)
                            AIHabitButton(name: "Parenting", category: "Family", color: .teal)
                            AIHabitButton(name: "Fitness", category: "Strength", color: .red)
                            AIHabitButton(name: "Self Love", category: "Wellness", color: .indigo)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    
                    Spacer()
                    
                    NavigationLink("Start Tracking") {
                        HabitsListView()
                    }
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white, in: Capsule())
                    .foregroundStyle(.blue)
                }
                .padding()
            }
        }
    }
}

struct AIHabitButton: View {
    let name: String
    let category: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            
            Text(category)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(color.opacity(0.2), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self)
}
