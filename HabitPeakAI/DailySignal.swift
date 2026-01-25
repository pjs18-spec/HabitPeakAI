//
//  DailySignal.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-24.
//

import Foundation
import SwiftData

@Model
final class DailySignal {
    var date: Date
    var movement: String
    var energy: String
    var nutrition: String
    var sleep: String
    var stress: String
    
    init(date: Date = .now,
         movement: String = "",
         energy: String = "",
         nutrition: String = "",
         sleep: String = "",
         stress: String = "") {
        self.date = date
        self.movement = movement
        self.energy = energy
        self.nutrition = nutrition
        self.sleep = sleep
        self.stress = stress
    }
}

extension DailySignal {
    var isComplete: Bool {
        !movement.isEmpty &&
        !energy.isEmpty &&
        !nutrition.isEmpty &&
        !sleep.isEmpty &&
        !stress.isEmpty
    }
}
