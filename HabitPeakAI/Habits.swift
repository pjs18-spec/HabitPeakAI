//
//  Habit.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2025-12-27.
//

import Foundation
import SwiftData

@Model
class Habit {
    var name: String
    var category: String
    var streak: Int
    var lastCompleted: Date?
    var aiSuggested: Bool
    var completionHistory: [Date]
    
    init(name: String, category: String = "General", streak: Int = 0, aiSuggested: Bool = false) {
        self.name = name
        self.category = category
        self.streak = streak
        self.aiSuggested = aiSuggested
        self.completionHistory = []
        self.lastCompleted = nil
    }
}

