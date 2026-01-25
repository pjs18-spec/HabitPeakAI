//
//  PreventiveInsightView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-08.
//

import SwiftUI

struct PreventiveInsightView: View {
    @Environment(\.presentationMode) var presentationMode
    let mainInsight: String
    let microInsights: [String]  // Array of supporting insights
    
    @State private var appear = false  // For animation
    
    var body: some View {
        ZStack {
            // Background
            Color("Background")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Header
                Text("Today’s Insight")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("PrimaryText"))
                
                // Main Insight
                Text(mainInsight)
                    .font(.body)
                    .foregroundColor(Color("PrimaryText"))
                    .lineSpacing(4)
                
                // Micro-Insight Cards
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(microInsights.enumerated()), id: \.offset) { index, insight in
                            MicroInsightCard(insight: insight)
                                .frame(minHeight: 80) // uniform height
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                                .animation(.easeOut.delay(Double(index) * 0.1), value: appear)
                        }
                    }
                }
                
                Spacer()
                
                // Done Button
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                        .foregroundColor(Color("ButtonText"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentPrimary"))
                        .cornerRadius(14)
                }
            }
            .padding()
            .onAppear {
                appear = true
            }
        }
    }
}

// MARK: - Micro Insight Card
struct MicroInsightCard: View {
    let insight: String
    
    var body: some View {
        Text(insight)
            .font(.subheadline)
            .foregroundColor(Color("PrimaryText"))
            .lineSpacing(3)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("CardBackground"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}
