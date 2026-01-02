//
//  LongevityHabitRules.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-01.
//

enum LongevityProfileField {
    case age
    case sex
    case bodyWeight
    case height
    case bodyFat
}
enum LongevityHabitType {
    case zone2
    case strength
    case protein
    case glucoseWalk
    case sleep

    var requiredProfileFields: [LongevityProfileField] {
        switch self {
        case .zone2:
            return [.age, .sex, .bodyWeight]
        case .strength:
            return [.age, .sex, .bodyWeight]
        case .protein:
            return [.bodyWeight]
        case .glucoseWalk:
            return [.age, .bodyWeight]
        case .sleep:
            return [.age, .sex]
        }
    }
}
