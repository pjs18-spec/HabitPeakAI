//
//  Habit.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2025-12-27.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id = UUID()
    var name: String
    var category: String
    var dateCreated = Date()
    
    // THESE FIX THE ERRORS:
    @Attribute(.unique) var streak: Int = 0
    var lastCompleted: Date?
    
    init(name: String, category: String) {
        self.name = name
        self.category = category
    }
}
