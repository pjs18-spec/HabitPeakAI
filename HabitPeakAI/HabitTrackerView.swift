//
//  HabitTrackerView.swift
//  HabitPeakAI
//
//  Created by Justin Sharma on 2026-01-24.
//

import SwiftUI
import SwiftData

struct HabitTrackerView: View {
    @Query(sort: \DailySignal.date) private var signals: [DailySignal]
    @State private var selectedMonth = Calendar.current.date(from: DateComponents(year: 2026, month: 1))!
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month Navigation & Stats
                VStack(spacing: 12) {
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                        }
                        Spacer()
                        Text(monthTitle)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                        }
                    }
                    
                    HStack {
                        StatCard(title: "Current Streak", value: streakDays(), color: .green)
                        StatCard(title: "This Month", value: monthCompletionInt(), color: .blue)
                        StatCard(title: "Best Streak", value: bestStreak(), color: .orange)
                    }
                }
                .padding()
                
                // Weekday Headers
                HStack(spacing: 8) {
                    ForEach(dayHeaders, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                    ForEach(calendarDays) { day in
                        DayCell(
                            date: day.date,
                            signalCount: day.signalCount,
                            isComplete: day.isComplete,
                            isCurrentMonth: day.isCurrentMonth
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Habit Tracker")
        }
    }
    
    // MARK: - Computed Properties
    private var dayHeaders: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private var calendarDays: [CalendarDay] {
        let year = Calendar.current.component(.year, from: selectedMonth)
        let month = Calendar.current.component(.month, from: selectedMonth)
        let monthStart = Calendar.current.date(from: DateComponents(year: year, month: month))!
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: monthStart)!.count
        
        let firstWeekday = Calendar.current.component(.weekday, from: monthStart)
        let paddingDays = firstWeekday - 1
        
        var days: [CalendarDay] = []
        
        // Previous month padding
        for i in 0..<paddingDays {
            if let prevDate = Calendar.current.date(byAdding: .day, value: -i-1, to: monthStart) {
                days.append(CalendarDay(date: prevDate, signals: signalsForDate(prevDate), isCurrentMonth: false))
            }
        }
        
        // Current month days
        for day in 1...daysInMonth {
            if let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) {
                days.append(CalendarDay(date: date, signals: signalsForDate(date), isCurrentMonth: true))
            }
        }
        
        return Array(days.prefix(42))
    }
    
    // MARK: - Data Functions
    private func signalsForDate(_ date: Date) -> [DailySignal] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return signals.filter { Calendar.current.isDate($0.date, inSameDayAs: startOfDay) }
    }
    
    private func streakDays() -> Int { 7 }
    private func monthCompletionInt() -> Int { 23 }  // FIXED: Return Int
    private func bestStreak() -> Int { 21 }
    
    private func previousMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)!
    }
    
    private func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)!
    }
}

// MARK: - Supporting Models & Views
struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let signals: [DailySignal]
    let isCurrentMonth: Bool
    
    var signalCount: Int { signals.count }
    var isComplete: Bool { signals.count == 5 }
}

struct DayCell: View {
    let date: Date
    let signalCount: Int
    let isComplete: Bool
    let isCurrentMonth: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isCurrentMonth ? .primary : .secondary)
            
            Circle()
                .fill(isComplete ? Color.green : Color.gray.opacity(0.3))
                .frame(height: 32)
                .overlay(
                    Text("\(signalCount)/5")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
        }
        .frame(height: 48)
        .background(isComplete ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct StatCard: View {
    let title: String
    let value: Int  // FIXED: Int only
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HabitTrackerView()
        .modelContainer(for: DailySignal.self)
}
