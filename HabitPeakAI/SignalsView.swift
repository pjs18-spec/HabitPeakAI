//
//  SignalsView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-25.
//

import SwiftUI
import SwiftData

struct SignalsView: View {
    
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Query Daily Signals
    @Query(sort: \DailySignal.date, order: .forward) private var signals: [DailySignal]
    
    // MARK: - Sample Data Loaded Flag
    @State private var isLoaded = false
    
    // MARK: - Computed Risk Scores
    private var heartRisk: Double {
        guard !signals.isEmpty else { return 1.0 }
        let recent = signals.suffix(7)
        let score = recent.map { signal in
            (movementWeight(signal.movement) + energyWeight(signal.energy) + stressWeight(signal.stress)) / 3.0
        }.average
        return score
    }
    
    private var cancerRisk: Double {
        guard !signals.isEmpty else { return 1.0 }
        let recent = signals.suffix(7)
        let score = recent.map { signal in
            (nutritionWeight(signal.nutrition) + sleepWeight(signal.sleep)) / 2.0
        }.average
        return score
    }
    
    private var neuroRisk: Double {
        guard !signals.isEmpty else { return 1.0 }
        let recent = signals.suffix(7)
        let score = recent.map { signal in
            (sleepWeight(signal.sleep) + stressWeight(signal.stress)) / 2.0
        }.average
        return score
    }
    
    private var diabetesRisk: Double {
        guard !signals.isEmpty else { return 1.0 }
        let recent = signals.suffix(7)
        let score = recent.map { signal in
            (nutritionWeight(signal.nutrition) + movementWeight(signal.movement) + energyWeight(signal.energy)) / 3.0
        }.average
        return score
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header with Back Button
                    HStack {
                        Button(action: {
                            dismiss() // Works if presented in sheet
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(Color("AccentPrimary"))
                        }
                        .padding(.trailing, 4)
                        
                        Text("Your Health Signals")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Load sample data if empty
                    if signals.isEmpty {
                        VStack(spacing: 16) {
                            Text("No signals yet")
                                .foregroundColor(.secondary)
                            Button("Load Sample Signals") {
                                loadSampleSignals()
                                isLoaded = true
                            }
                            .padding()
                            .background(Color("AccentPrimary"))
                            .foregroundColor(Color("ButtonText"))
                            .cornerRadius(12)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                    
                    // Risk Cards
                    if !signals.isEmpty {
                        riskCard(title: "Heart Disease", risk: heartRisk, relatedSignals: ["Movement", "Energy", "Stress"])
                        riskCard(title: "Cancer", risk: cancerRisk, relatedSignals: ["Nutrition", "Sleep"])
                        riskCard(title: "Neurodegenerative Disease", risk: neuroRisk, relatedSignals: ["Sleep", "Stress"])
                        riskCard(title: "Type 2 Diabetes", risk: diabetesRisk, relatedSignals: ["Nutrition", "Movement", "Energy"])
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .onAppear {
                if signals.isEmpty && !isLoaded {
                    loadSampleSignals()
                    isLoaded = true
                }
            }
        }
    }
    
    // MARK: - Risk Card
    private func riskCard(title: String, risk: Double, relatedSignals: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(riskColor(for: risk))
                    .frame(width: 18, height: 18)
            }
            
            HStack(spacing: 6) {
                ForEach(relatedSignals, id: \.self) { signal in
                    Text(signal)
                        .font(.caption2)
                        .padding(6)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            // Mini trend bar for last 7 days
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { i in
                    let value = trendValue(for: title, dayOffset: i)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(riskColor(for: value))
                        .frame(height: 10)
                }
            }
        }
        .padding()
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
    }
    
    // MARK: - Trend & Risk Helpers
    private func trendValue(for title: String, dayOffset: Int) -> Double {
        guard signals.count > dayOffset else { return 1.0 }
        let signal = signals[signals.count - 1 - dayOffset]
        switch title {
        case "Heart Disease":
            return (movementWeight(signal.movement) + energyWeight(signal.energy) + stressWeight(signal.stress)) / 3.0
        case "Cancer":
            return (nutritionWeight(signal.nutrition) + sleepWeight(signal.sleep)) / 2.0
        case "Neurodegenerative Disease":
            return (sleepWeight(signal.sleep) + stressWeight(signal.stress)) / 2.0
        case "Type 2 Diabetes":
            return (nutritionWeight(signal.nutrition) + movementWeight(signal.movement) + energyWeight(signal.energy)) / 3.0
        default:
            return 1.0
        }
    }
    
    private func riskColor(for score: Double) -> Color {
        switch score {
        case 0..<0.4: return .green
        case 0.4..<0.7: return .yellow
        default: return .red
        }
    }
    
    // MARK: - Signal Weights
    private func movementWeight(_ value: String) -> Double {
        switch value { case "Strong": return 0.0; case "Moderate": return 0.5; default: return 1.0 }
    }
    
    private func energyWeight(_ value: String) -> Double {
        switch value { case "High": return 0.0; case "Steady": return 0.5; default: return 1.0 }
    }
    
    private func nutritionWeight(_ value: String) -> Double {
        switch value { case "Intentional": return 0.0; case "Balanced": return 0.5; default: return 1.0 }
    }
    
    private func sleepWeight(_ value: String) -> Double {
        switch value { case "Restorative": return 0.0; case "Okay": return 0.5; default: return 1.0 }
    }
    
    private func stressWeight(_ value: String) -> Double {
        switch value { case "Low": return 0.0; case "Moderate": return 0.5; default: return 1.0 }
    }
    
    // MARK: - Load Sample Signals
    private func loadSampleSignals() {
        let sample = DailySignal(
            date: Date(),
            movement: "Moderate",
            energy: "Steady",
            nutrition: "Balanced",
            sleep: "Okay",
            stress: "Moderate"
        )
        modelContext.insert(sample)
        try? modelContext.save()
    }
}

// MARK: - Array Average Helper
extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 1.0 }
        return reduce(0, +) / Double(count)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SignalsView()
            .modelContainer(for: DailySignal.self)
    }
}
