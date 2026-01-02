//
//  LongevityProfile.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-01.
//

import Foundation
import SwiftData

@Model
final class LongevityProfile {

    // MARK: - Required Baseline Inputs
    var age: Int
    var sex: BiologicalSex
    var bodyWeightKg: Double

    // MARK: - Optional Precision Inputs
    var heightCm: Double?
    var bodyFatPercent: Double?

    // MARK: - Metadata
    var lastUpdated: Date

    // MARK: - Init
    init(
        age: Int,
        sex: BiologicalSex,
        bodyWeightKg: Double,
        heightCm: Double? = nil,
        bodyFatPercent: Double? = nil,
        lastUpdated: Date = Date()
    ) {
        self.age = age
        self.sex = sex
        self.bodyWeightKg = bodyWeightKg
        self.heightCm = heightCm
        self.bodyFatPercent = bodyFatPercent
        self.lastUpdated = lastUpdated
    }
}
