//
//  LongevityProfileManager.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-01.
//

import Foundation
import SwiftData
import Observation

@Observable
final class LongevityProfileManager {
    private let modelContext: ModelContext
    
    // ✅ Remove @Published - @Observable handles this automatically
    var profile: LongevityProfile?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.profile = fetchProfile()
    }
    
    func updateProfile(
        age: Int,
        sex: BiologicalSex,
        bodyWeightKg: Double,
        heightCm: Double?,
        bodyFatPercent: Double?
    ) {
        if let existingProfile = profile {
            existingProfile.age = age
            existingProfile.sex = sex
            existingProfile.bodyWeightKg = bodyWeightKg
            existingProfile.heightCm = heightCm
            existingProfile.bodyFatPercent = bodyFatPercent
            existingProfile.lastUpdated = Date()
        } else {
            let newProfile = LongevityProfile(
                age: age,
                sex: sex,
                bodyWeightKg: bodyWeightKg,
                heightCm: heightCm,
                bodyFatPercent: bodyFatPercent
            )
            modelContext.insert(newProfile)
            profile = newProfile
        }
        saveContext()
    }
    
    func refreshProfile() {
        profile = fetchProfile()
    }
    
    private func fetchProfile() -> LongevityProfile? {
        let descriptor = FetchDescriptor<LongevityProfile>(
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    private func saveContext() {
        try? modelContext.save()
    }
}
