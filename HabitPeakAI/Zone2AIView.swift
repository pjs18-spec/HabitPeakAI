import SwiftUI
import SwiftData

struct Zone2AIView: View {
    let habitName: String
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var userInput = ""
    @State private var aiResponse = ""
    @State private var isGenerating = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.green.opacity(0.8), .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // AI Header
                VStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                    Text("\(habitName) AI")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text("Enter your data for personalized AI plan")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                // User Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Data:")
                        .font(.headline)
                        .foregroundStyle(.white)
                    TextField("Ex: Weight 180lbs, HR 120-140bpm", text: $userInput)
                        .padding()
                        .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                        .tint(.white)
                }
                .font(.body)
                
                // Generate Button
                Button(action: generateAIResponse) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundStyle(.white)
                        }
                        Text(isGenerating ? "Generating..." : "Generate AI Plan")
                            .font(.title2.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white, in: Capsule())
                    .foregroundStyle(.green)
                }
                .disabled(userInput.isEmpty || isGenerating)
                
                // AI Response
                if !aiResponse.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Plan:")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(aiResponse)
                            .font(.body)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Spacer()
                
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
            .padding()
        }
    }
    
    private func generateAIResponse() {
        isGenerating = true
        // Simulate AI (replace with real API later)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            aiResponse = aiResponseForHabit()
            isGenerating = false
        }
    }
    
    private func aiResponseForHabit() -> String {
        switch habitName {
        case "Zone 2 Lock-In":
            return "🎯 **Zone 2 Plan:** Run 50min at 125-135bpm (70% max HR). Your input: \(userInput). Target: Fat burn zone. Track HR every 5min."
        case "Strength Anchor":
            return "💪 **Lift Protocol:** 5x5 Squat @ 70% 1RM. Rest 3min. Your weight: \(userInput). Add 5lbs next session."
        case "Protein Floor Hit":
            return "🍗 **Protein Target:** \(calculateProtein(userInput)). Hit 144g today. Sources: Chicken, eggs, whey."
        default:
            return "AI analyzing your input: \(userInput)..."
        }
    }
    
    private func calculateProtein(_ input: String) -> String {
        // Simple parser: "Weight 180lbs" → 144g
        if let weight = input.components(separatedBy: "Weight ").last?.replacingOccurrences(of: "lbs", with: "").components(separatedBy: " ").first,
           let lbs = Double(weight) {
            return "\(Int(lbs * 0.8))g"
        }
        return "144g"
    }
    
    private func saveAIHabit() {
        let habit = Habit(name: "\(habitName): \(aiResponse.prefix(30))...", category: "Longevity")
        modelContext.insert(habit)
        print("✅ AI Habit Saved!")
    }
}

#Preview {
    Zone2AIView(habitName: "Zone 2 Lock-In")
        .modelContainer(for: Habit.self)
}
