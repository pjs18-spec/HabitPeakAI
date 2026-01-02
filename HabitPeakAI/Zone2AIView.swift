//
//  Zone2AIView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-01.
//

import SwiftUI
import SwiftData
import Observation

struct Zone2AIView: View {

    let habitName: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // ✅ Use plain property since LongevityProfileManager is @Observable
    @State private var profileManager: LongevityProfileManager

    @State private var duration = 45
    @State private var hrInput = ""
    @State private var effort = 7
    @State private var aiResponse = ""
    @State private var isGenerating = false

    // MARK: - Init
    init(habitName: String, modelContext: ModelContext) {
        self.habitName = habitName
        self.profileManager = LongevityProfileManager(modelContext: modelContext)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.green.opacity(0.8), .blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                header
                sessionInputs
                analyzeButton
                aiOutput
                Spacer()
                saveButton
            }
            .padding()
        }
    }
}

// MARK: - UI Sections
private extension Zone2AIView {

    var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundStyle(.white)

            Text("\(habitName) AI")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Log your session for AI analysis")
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    var sessionInputs: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Data")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                HStack {
                    Text("Duration")
                        .foregroundStyle(.white)
                        .frame(width: 80)

                    Picker("min", selection: $duration) {
                        ForEach(20...90, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                HStack {
                    Text("Avg HR")
                        .foregroundStyle(.white)
                        .frame(width: 80)

                    TextField("120", text: $hrInput)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text("Effort")
                        .foregroundStyle(.white)
                        .frame(width: 80)

                    Picker("1-10", selection: $effort) {
                        ForEach(1...10, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding()
            .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    var analyzeButton: some View {
        Button(action: generateAIResponse) {
            HStack {
                if isGenerating { ProgressView().scaleEffect(0.8).foregroundStyle(.white) }
                Text(isGenerating ? "Analyzing..." : "Analyze Session")
                    .font(.title2.bold())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.white, in: Capsule())
            .foregroundStyle(.green)
        }
        .disabled(isGenerating)
    }

    var aiOutput: some View {
        Group {
            if !aiResponse.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Analysis")
                        .foregroundStyle(.white)

                    Text(aiResponse)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    var saveButton: some View {
        Button("← Save & Back") {
            saveAIHabit()
            dismiss()
        }
        .font(.title2.bold())
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white, in: Capsule())
        .foregroundStyle(.green)
        .disabled(aiResponse.isEmpty)
    }
}

// MARK: - AI Logic
private extension Zone2AIView {

    func generateAIResponse() {
        guard let profile = profileManager.profile else {
            aiResponse = "Please create your Longevity Profile first."
            return
        }

        isGenerating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // ✅ Fetch last 5 Zone2 sessions linked to this profile
            let descriptor = FetchDescriptor<Zone2Session>(
                predicate: #Predicate { $0.profile == profile },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let recentSessions = Array((try? modelContext.fetch(descriptor))?.prefix(5) ?? [])

            // Generate AI response
            aiResponse = aiResponseForHabit(profile, recentSessions)

            // Log new session
            logSession(profile)

            isGenerating = false
        }
    }

    func aiResponseForHabit(_ profile: LongevityProfile, _ recentSessions: [Zone2Session]) -> String {
        guard !recentSessions.isEmpty else {
            return baselineRecommendation(profile)
        }

        let avgDuration = recentSessions.map { $0.duration }.average()
        let avgEffort = recentSessions.map { Double($0.effort) }.average()

        let aerobicSignal = min(100, Double(avgDuration) / 50.0 * 8 + avgEffort * 2)

        return "✅ Avg \(Int(avgDuration))min | Effort \(Int(avgEffort))/10. Aerobic Signal: \(Int(aerobicSignal))."
    }

    func baselineRecommendation(_ profile: LongevityProfile) -> String {
        let maxHR = 220 - profile.age
        let zone2 = Int(Double(maxHR) * 0.7)
        return "🎯 Start \(duration)min @ \(zone2)–\(zone2 + 10)bpm, 3x/week."
    }

    func logSession(_ profile: LongevityProfile) {
        let hrValue = Int(hrInput).flatMap { $0 > 0 ? $0 : nil }
        let session = Zone2Session(
            duration: duration,
            avgHR: hrValue,
            effort: effort,
            date: Date(),
            profile: profile
        )
        modelContext.insert(session)
    }

    func saveAIHabit() {
        modelContext.insert(
            Habit(
                name: "\(habitName): \(duration)min",
                category: "Longevity"
            )
        )
    }
}

// MARK: - Helpers
extension Array where Element == Int {
    func average() -> Double {
        isEmpty ? 0 : Double(reduce(0, +)) / Double(count)
    }
}

extension Array where Element == Double {
    func average() -> Double {
        isEmpty ? 0 : reduce(0, +) / Double(count)
    }
}

// MARK: - Preview
#Preview {
    let container = try! ModelContainer(
        for: Habit.self,
        LongevityProfile.self,
        Zone2Session.self
    )
    return Zone2AIView(
        habitName: "Zone 2 Lock-In",
        modelContext: container.mainContext
    )
}
