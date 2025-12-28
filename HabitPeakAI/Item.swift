//
//  Item.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2025-12-27.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
