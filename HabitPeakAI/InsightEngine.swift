//
//  InsightEngine.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-08.
//

import Foundation

// MARK: - Insight Category
enum InsightCategory: String {
    case sleepConsistency = "Sleep Consistency"
    case stressLoad = "Stress Load"
    case movementLoad = "Daily Movement"
    case nutritionAlignment = "Nutrition Alignment"
    case baselineStability = "Baseline Stability"
}

// MARK: - Daily Signals Model
struct DailySignals {
    let movement: String
    let energy: String
    let nutrition: String
    let sleep: String
    let stress: String
}

// MARK: - Insight Result
struct InsightResult {
    let mainInsight: String
    let microInsights: [String]
}

// MARK: - Insight Engine
struct InsightEngine {
    
    // Public entry point
    static func generateInsight(from signals: DailySignals) -> InsightResult {
        // Determine main constraint
        let primaryCategory = determinePrimaryConstraint(from: signals)
        
        // Generate main insight
        let main = mainInsightText(for: primaryCategory, signals: signals)
        
        // Generate up to 5 micro-insights
        let micro = generateMicroInsights(from: signals, maxCount: 5)
        
        return InsightResult(mainInsight: main, microInsights: micro)
    }
    
    // MARK: - Primary Constraint Logic
    private static func determinePrimaryConstraint(from signals: DailySignals) -> InsightCategory {
        if signals.sleep == "Fragmented" { return .sleepConsistency }
        if signals.stress == "High" { return .stressLoad }
        if signals.movement == "Low" { return .movementLoad }
        if signals.nutrition == "Off Track" { return .nutritionAlignment }
        return .baselineStability
    }
    
    // MARK: - Main Insight Templates
    private static func mainInsightText(for category: InsightCategory, signals: DailySignals) -> String {
        switch category {
        case .sleepConsistency:
            return signals.energy == "Low"
                ? "Sleep was fragmented, limiting recovery and energy today. Prioritizing a consistent wind-down tonight may improve tomorrow’s energy."
                : "Sleep was slightly fragmented. Maintaining consistency tonight supports tomorrow’s baseline."
            
        case .stressLoad:
            return "Stress is elevated today. Brief decompression or meditation this evening can help restore balance."
            
        case .movementLoad:
            return "Movement was lower than usual today. Even light activity, like a short walk, can support circulation and energy."
            
        case .nutritionAlignment:
            return "Nutrition is slightly off track today. A balanced, protein-forward meal may stabilize energy and recovery."
            
        case .baselineStability:
            return "Signals are broadly aligned today. Maintaining this balance supports long-term health."
        }
    }
    
    // MARK: - Micro-Insights Logic
    private static func generateMicroInsights(from signals: DailySignals, maxCount: Int) -> [String] {
        var insights: [String] = []
        
        // Individual Signal Insights
        let signalInsights: [String] = [
            movementInsight(for: signals.movement, energy: signals.energy),
            energyInsight(for: signals.energy),
            nutritionInsight(for: signals.nutrition, energy: signals.energy),
            sleepInsight(for: signals.sleep, energy: signals.energy),
            stressInsight(for: signals.stress, sleep: signals.sleep)
        ]
        
        // Add only non-empty insights
        insights.append(contentsOf: signalInsights.filter { !$0.isEmpty })
        
        // Positive reinforcement
        insights.append("Small positive habits compound over time — consistency matters more than perfection.")
        
        // Limit to maxCount
        if insights.count > maxCount {
            insights = Array(insights.prefix(maxCount))
        }
        
        return insights
    }
    
    // MARK: - Individual Signal Insight Functions
    private static func movementInsight(for movement: String, energy: String) -> String {
        switch movement {
        case "Low":
            return energy != "High" ? "Low movement today — even a short walk supports circulation and energy." : "Low movement today, but high energy persists — good balance overall."
        case "Moderate":
            return "Moderate movement — consistent activity supports recovery."
        case "Strong":
            return "Strong movement today — excellent for energy and circulation."
        default:
            return ""
        }
    }
    
    private static func energyInsight(for energy: String) -> String {
        switch energy {
        case "Low":
            return "Energy is low — consider hydration, light activity, or short breaks to restore balance."
        case "Steady":
            return "Energy is steady — good consistency throughout the day."
        case "High":
            return "High energy today — leverage it for important tasks or habits."
        default:
            return ""
        }
    }
    
    private static func nutritionInsight(for nutrition: String, energy: String) -> String {
        switch nutrition {
        case "Off Track":
            return energy != "High" ? "Nutrition is off track — focus on balanced meals with protein and fiber." : "Nutrition is off track, but energy is high — opportunity to optimize recovery."
        case "Balanced":
            return "Nutrition is balanced — supporting energy and recovery."
        case "Intentional":
            return "Intentional nutrition today — excellent habit formation."
        default:
            return ""
        }
    }
    
    private static func sleepInsight(for sleep: String, energy: String) -> String {
        switch sleep {
        case "Fragmented":
            return energy == "Low" ? "Fragmented sleep plus low energy today — consider a calming evening routine." : "Sleep was fragmented — prioritize rest tonight for recovery."
        case "Okay":
            return "Sleep was okay — minor adjustments may improve tomorrow’s baseline."
        case "Restorative":
            return "Restorative sleep — excellent for recovery and energy."
        default:
            return ""
        }
    }
    
    private static func stressInsight(for stress: String, sleep: String) -> String {
        switch stress {
        case "Low":
            return "Stress is low — maintain this calm state to support recovery."
        case "Moderate":
            return "Moderate stress — brief relaxation exercises may help."
        case "High":
            return sleep != "Restorative" ? "High stress and less-than-restorative sleep may amplify fatigue — consider meditation or early bedtime." : "High stress — short decompression can help restore balance."
        default:
            return ""
        }
    }
}
