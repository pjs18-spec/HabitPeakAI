//
//  Zone2Session.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-01.
//

import Foundation
import SwiftData

@Model
final class Zone2Session {
    var duration: Int
    var avgHR: Int?
    var effort: Int
    var date: Date
    var profile: LongevityProfile

    init(duration: Int, avgHR: Int?, effort: Int, date: Date, profile: LongevityProfile) {
        self.duration = duration
        self.avgHR = avgHR
        self.effort = effort
        self.date = date
        self.profile = profile
    }
}
