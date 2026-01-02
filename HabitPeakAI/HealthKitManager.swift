//
//  HealthkitManager.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2025-12-28.
//

import Foundation
import HealthKit

final class HealthKitManager {
    // Shared singleton you call from anywhere: HealthKitManager.shared
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    private init() { }

    // MARK: - Authorization

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // Make sure HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        // What you want to READ
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        // You aren’t writing any data yet, so write set is empty
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    // MARK: - Latest Heart Rate

    func fetchLatestHeartRate(completion: @escaping (Double?) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: type,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sort]) { _, samples, _ in
            guard
                let sample = samples?.first as? HKQuantitySample
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let bpm = sample.quantity.doubleValue(for: unit)

            DispatchQueue.main.async {
                completion(bpm)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Steps Between Two Dates

    func fetchSteps(from start: Date, to end: Date, completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: start,
                                                    end: end,
                                                    options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, stats, _ in
            let steps = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0

            DispatchQueue.main.async {
                completion(steps)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Last Night Sleep (hours)

    func fetchLastNightSleepHours(completion: @escaping (Double?) -> Void) {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil)
            return
        }

        let now = Date()
        let start = Calendar.current.date(byAdding: .day, value: -1, to: now)!

        let predicate = HKQuery.predicateForSamples(withStart: start,
                                                    end: now,
                                                    options: .strictEndDate)

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: type,
                                  predicate: predicate,
                                  limit: 50,
                                  sortDescriptors: [sort]) { _, samples, _ in
            guard let categorySamples = samples as? [HKCategorySample] else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let asleepSamples = categorySamples.filter {
                $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            }

            let totalSeconds = asleepSamples.reduce(0.0) { partial, sample in
                partial + sample.endDate.timeIntervalSince(sample.startDate)
            }

            let hours = totalSeconds / 3600.0
            DispatchQueue.main.async {
                completion(hours == 0 ? nil : hours)
            }
        }

        healthStore.execute(query)
    }
}
