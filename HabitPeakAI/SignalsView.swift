//
//  SignalsView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-25.
//

import SwiftUI
import SwiftData

struct SignalsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailySignal.date, order: .forward) private var signals: [DailySignal]
    
    @State private var isLoaded = false
    
    private var heartRisk: Double {
        signals.suffix(7).map { (movementWeight($0.movement) + energyWeight($0.energy) + stressWeight($0.stress)) / 3.0 }.average
    }
    private var cancerRisk: Double {
        signals.suffix(7).map { (nutritionWeight($0.nutrition) + sleepWeight($0.sleep)) / 2.0 }.average
    }
    private var neuroRisk: Double {
        signals.suffix(7).map { (sleepWeight($0.sleep) + stressWeight($0.stress)) / 2.0 }.average
    }
    private var diabetesRisk: Double {
        signals.suffix(7).map { (nutritionWeight($0.nutrition) + movementWeight($0.movement) + energyWeight($0.energy)) / 3.0 }.average
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Your Health Signals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                if signals.isEmpty {
                    VStack(spacing: 16) {
                        Text("No signals yet").foregroundColor(.secondary)
                        Button("Load Sample Signals") {
                            loadSampleSignals()
                            isLoaded = true
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("AccentPrimary")) // fallback: .blue
                        .foregroundColor(Color("ButtonText")) // fallback: .white
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                
                if !signals.isEmpty {
                    riskCard(title: "Heart Disease", risk: heartRisk, relatedSignals: ["Movement","Energy","Stress"])
                    riskCard(title: "Cancer", risk: cancerRisk, relatedSignals: ["Nutrition","Sleep"])
                    riskCard(title: "Neurodegenerative Disease", risk: neuroRisk, relatedSignals: ["Sleep","Stress"])
                    riskCard(title: "Type 2 Diabetes", risk: diabetesRisk, relatedSignals: ["Nutrition","Movement","Energy"])
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("Signals")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if signals.isEmpty && !isLoaded {
                loadSampleSignals()
                isLoaded = true
            }
        }
    }
    
    // MARK: - Risk Card
    private func riskCard(title: String, risk: Double, relatedSignals: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Circle().fill(riskColor(for: risk)).frame(width: 18, height: 18)
            }
            HStack(spacing: 6) {
                ForEach(relatedSignals, id: \.self) { Text($0).font(.caption2).padding(6).background(Color.gray.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 6)) }
            }
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { i in
                    let value = trendValue(for: title, dayOffset: i)
                    RoundedRectangle(cornerRadius: 3).fill(riskColor(for: value)).frame(height: 10)
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
        case "Heart Disease": return (movementWeight(signal.movement)+energyWeight(signal.energy)+stressWeight(signal.stress))/3
        case "Cancer": return (nutritionWeight(signal.nutrition)+sleepWeight(signal.sleep))/2
        case "Neurodegenerative Disease": return (sleepWeight(signal.sleep)+stressWeight(signal.stress))/2
        case "Type 2 Diabetes": return (nutritionWeight(signal.nutrition)+movementWeight(signal.movement)+energyWeight(signal.energy))/3
        default: return 1.0
        }
    }
    
    private func riskColor(for score: Double) -> Color {
        switch score { case 0..<0.4: return .green; case 0.4..<0.7: return .yellow; default: return .red }
    }
    
    // MARK: - Signal Weights
    private func movementWeight(_ value: String) -> Double { value=="Strong" ? 0 : value=="Moderate" ? 0.5 : 1 }
    private func energyWeight(_ value: String) -> Double { value=="High" ? 0 : value=="Steady" ? 0.5 : 1 }
    private func nutritionWeight(_ value: String) -> Double { value=="Intentional" ? 0 : value=="Balanced" ? 0.5 : 1 }
    private func sleepWeight(_ value: String) -> Double { value=="Restorative" ? 0 : value=="Okay" ? 0.5 : 1 }
    private func stressWeight(_ value: String) -> Double { value=="Low" ? 0 : value=="Moderate" ? 0.5 : 1 }
    
    // MARK: - Load Sample Signals
    private func loadSampleSignals() {
        (0..<7).forEach { _ in
            let s = DailySignal(date: Date(), movement: "Moderate", energy: "Steady", nutrition: "Balanced", sleep: "Okay", stress: "Moderate")
            modelContext.insert(s)
        }
        try? modelContext.save()
    }
}

// MARK: - Array Average Helper
extension Array where Element == Double {
    var average: Double { isEmpty ? 1.0 : reduce(0,+)/Double(count) }
}

// MARK: - Preview
#Preview {
    NavigationStack { SignalsView() }
        .modelContainer(for: DailySignal.self)
}
