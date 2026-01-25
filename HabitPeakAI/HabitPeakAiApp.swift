//
//  DailySignalView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-08.
//

import SwiftUI
import SwiftData

struct DailySignalView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - User Selections
    @State private var movement = ""
    @State private var energy = ""
    @State private var nutrition = ""
    @State private var sleep = ""
    @State private var stress = ""
    
    // MARK: - Insight State
    @State private var showInsight = false
    @State private var mainInsight: String = ""
    @State private var microInsights: [String] = []
    
    // MARK: - Animation & Loading States
    @State private var cardSelected: [String: Bool] = [:]
    @State private var pulse = false
    @State private var isGeneratingInsight = false
    
    // MARK: - Daily Reset Tracking
    @AppStorage("lastSignalDate") private var lastSignalDate = Date.distantPast
    
    // MARK: - Options
    let movementOptions = ["Low", "Moderate", "Strong"]
    let energyOptions = ["Low", "Steady", "High"]
    let nutritionOptions = ["Off Track", "Balanced", "Intentional"]
    let sleepOptions = ["Fragmented", "Okay", "Restorative"]
    let stressOptions = ["Low", "Moderate", "High"]
    
    // MARK: - Computed
    var allComplete: Bool {
        ![movement, energy, nutrition, sleep, stress].contains("")
    }
    
    var shouldResetDaily: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDate = Calendar.current.startOfDay(for: lastSignalDate)
        return today > lastDate
    }
    
    // MARK: - Body (FIXED - NO TAB BAR OVERLAP)
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Header with Reset Button
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Today's Signals")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("PrimaryText"))
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "chart.xyaxis.line")
                                        .font(.subheadline)
                                    Text("Your health snapshot")
                                        .font(.subheadline)
                                        .foregroundColor(Color("SecondaryText"))
                                }
                                
                                if shouldResetDaily {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.clockwise")
                                        Text("New day - ready to log!")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: resetSignals) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                                    .foregroundColor(allComplete ? Color("SecondaryText") : Color.gray.opacity(0.4))
                                    .frame(width: 44, height: 42)
                                    .background(Color.clear)
                                    .clipShape(Circle())
                            }
                            .opacity(allComplete ? 1.0 : 0.4)
                        }
                        .padding(.top, 8)
                        
                        // Signal Cards - TIGHTER SPACING
                        VStack(spacing: 8) {
                            SignalCard(title: "Movement", selection: $movement, options: movementOptions, cardSelected: $cardSelected)
                            SignalCard(title: "Energy", selection: $energy, options: energyOptions, cardSelected: $cardSelected)
                            SignalCard(title: "Nutrition", selection: $nutrition, options: nutritionOptions, cardSelected: $cardSelected)
                            SignalCard(title: "Sleep", selection: $sleep, options: sleepOptions, cardSelected: $cardSelected)
                            SignalCard(title: "Stress Load", selection: $stress, options: stressOptions, cardSelected: $cardSelected)
                        }
                        
                        // FIXED Bottom Section - NO OVERLAP
                        VStack(spacing: 12) {
                            Divider()
                                .background(Color("Divider"))
                                .opacity(0.5)
                            
                            Button(action: generateInsights) {
                                HStack {
                                    if isGeneratingInsight {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    }
                                    Text(isGeneratingInsight ? "Generating..." : "View Today's Insight")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .foregroundColor(Color("ButtonText"))
                            .background(Color("AccentPrimary"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                            
                            // FORCE CLEARANCE ABOVE TAB BAR
                            Spacer(minLength: 220)
                        }
                        .disabled(!allComplete || isGeneratingInsight)
                        .opacity(allComplete && !isGeneratingInsight ? 1.0 : 0.6)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationViewStyle(.stack)
            .navigationBarHidden(true)
            .sheet(isPresented: $showInsight) {
                PreventiveInsightView(mainInsight: mainInsight, microInsights: microInsights)
            }
            .onAppear(perform: checkDailyReset)
            .onChange(of: allComplete) { _, newValue in
                pulse = newValue && !isGeneratingInsight
            }
        }
    }
    
    // MARK: - Actions (MOVED OUTSIDE body)
    func generateInsights() {
        // 🚀 SAVE TO SWIFT DATA FIRST
        let signal = DailySignal(
            date: Date(),
            movement: movement,
            energy: energy,
            nutrition: nutrition,
            sleep: sleep,
            stress: stress
        )
        modelContext.insert(signal)
        try? modelContext.save()
        
        // Existing insight logic
        isGeneratingInsight = true
        mainInsight = ""
        microInsights = []
        
        Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 1_500_000_000)
                
                let signals = DailySignals(
                    movement: movement,
                    energy: energy,
                    nutrition: nutrition,
                    sleep: sleep,
                    stress: stress
                )
                
                let result = InsightEngine.generateInsight(from: signals)
                mainInsight = result.mainInsight
                microInsights = result.microInsights
                
                if !mainInsight.isEmpty && !microInsights.isEmpty {
                    showInsight = true
                }
            } catch {
                print("Insight generation failed: \(error)")
            }
            
            isGeneratingInsight = false
        }
    }
    
    func resetSignals() {
        withAnimation(.easeInOut(duration: 0.3)) {
            movement = ""
            energy = ""
            nutrition = ""
            sleep = ""
            stress = ""
            cardSelected = [:]
        }
    }
    
    func checkDailyReset() {
        if shouldResetDaily {
            resetSignals()
            lastSignalDate = Date()
        }
    }
    
    // MARK: - Signal Card (UNCHANGED)
    struct SignalCard: View {
        let title: String
        @Binding var selection: String
        let options: [String]
        @Binding var cardSelected: [String: Bool]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color("PrimaryText"))
                
                HStack(spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selection = option
                                cardSelected[option] = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation {
                                    cardSelected[option] = false
                                }
                            }
                        } label: {
                            Text(option)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(
                                    selection == option
                                    ? Color("ButtonText")
                                    : Color("SecondaryText")
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    selection == option
                                    ? Color("AccentPrimary")
                                    : Color.clear
                                )
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("CardBorder"))
                                )
                                .scaleEffect(cardSelected[option] ?? false ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cardSelected[option])
                        }
                    }
                }
            }
            .padding()
            .frame(minHeight: 110)
            .background(Color("CardBackground"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    DailySignalView()
        .modelContainer(for: DailySignal.self)
}



