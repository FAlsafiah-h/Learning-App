import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
	@Published var learningTopic: String
	@Published var selectedTimeframe: String
	@Published var days: [DayActivity] = []
	@Published var selectedDayId: Int = 0
	@Published var freezesUsed: Int = 0
	@Published var showOnboarding: Bool = false
	
	@Published var lastActivityDate: Date? {
		didSet {
			UserDefaults.standard.set(lastActivityDate, forKey: "lastActivityDate")
		}
	}
	
	private let maxInactivitySeconds: TimeInterval = 32 * 60 * 60 // 32 hours
	
	var requiredGoalDays: Int {
		switch selectedTimeframe {
		case "Week": return 7
		case "Month": return 30
		case "Year": return 365
		default: return 7
		}
	}
	
	var maxFreezes: Int {
		switch selectedTimeframe {
		case "Week": return 2
		case "Month": return 8
		case "Year": return 96
		default: return 2
		}
	}
	
	init(learningTopic: String, selectedTimeframe: String = "Week") {
		self.learningTopic = learningTopic
		self.selectedTimeframe = selectedTimeframe
		self.days = ActivityViewModel.generateDays(for: selectedTimeframe)
		self.lastActivityDate = UserDefaults.standard.object(forKey: "lastActivityDate") as? Date
		
		loadSavedStatuses()
		selectToday()
		checkStreakExpiration()
	}
	
	static func generateDays(for timeframe: String) -> [DayActivity] {
		let calendar = Calendar.current
		let today = Date()
		let count: Int
		
		switch timeframe {
		case "Week": count = 7
		case "Month": count = 30
		case "Year": count = 365
		default: count = 7
		}
		
		var generated: [DayActivity] = []
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE"
		
		for i in 0..<count {
			if let date = calendar.date(byAdding: .day, value: i, to: today) {
				let fullDayName = formatter.string(from: date)
				let singleLetter = String(fullDayName.prefix(1))
				let dayNumber = calendar.component(.day, from: date)
				
				generated.append(DayActivity(id: i, dayName: singleLetter, dateNumber: dayNumber, status: .empty))
			}
		}
		return generated
	}
	
	private func selectToday() {
		let calendar = Calendar.current
		let todayNumber = calendar.component(.day, from: Date())
		if let match = days.first(where: { $0.dateNumber == todayNumber }) {
			self.selectedDayId = match.id
		} else if let first = days.first {
			self.selectedDayId = first.id
		}
	}
	
	var formattedCurrentDate: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, d MMMM"
		return formatter.string(from: Date())
	}

	var isLearningPeriodOver: Bool {
		return selectedDayId >= days.count - 1
	}

	var learnedDaysCount: Int {
		days.filter { $0.status == .learned }.count
	}
	
	var freezedDaysCount: Int {
		days.filter { $0.status == .freezed }.count
	}
	
	var isGoalMet: Bool {
		(learnedDaysCount + freezedDaysCount) >= requiredGoalDays
	}
	
	var selectedDay: DayActivity {
		days.first(where: { $0.id == selectedDayId }) ?? days[0]
	}
	
	var mainButtonText: String {
		switch selectedDay.status {
		case .learned: return "Logged as Learned"
		case .freezed: return "Day Freezed"
		case .empty: return "Log as Learned"
		}
	}
	
	var freezeButtonText: String {
		if selectedDay.status == .learned { return "Day logged as learned" }
		else if selectedDay.status == .freezed { return "Freezed for a day" }
		else if freezesUsed >= maxFreezes { return "Out of freezes" }
		else { return "Freeze for a day" }
	}
	
	var isMainButtonDisabled: Bool {
		return selectedDay.status == .freezed || isLearningPeriodOver
	}
	
	var isFreezeButtonDisabled: Bool {
		return freezesUsed >= maxFreezes || selectedDay.status != .empty || isLearningPeriodOver
	}
	
	func selectDay(id: Int) {
		selectedDayId = id
	}
	
	// Helper to get exact date for any day in the dashboard list
	func date(for day: DayActivity) -> Date {
		let calendar = Calendar.current
		return calendar.date(byAdding: .day, value: day.id, to: Date()) ?? Date()
	}
	
	func toggleLogStatus() {
		guard !isLearningPeriodOver else { return }
		checkStreakExpiration()
		
		if let index = days.firstIndex(where: { $0.id == selectedDayId }) {
			if days[index].status == .learned {
				days[index].status = .empty
			} else if days[index].status == .empty {
				days[index].status = .learned
				lastActivityDate = Date()
			}
			saveStatus(for: days[index], actualDate: date(for: days[index]))
		}
	}
	
	func freezeDay() {
		guard !isLearningPeriodOver else { return }
		checkStreakExpiration()
		
		if let index = days.firstIndex(where: { $0.id == selectedDayId }) {
			if days[index].status == .empty && freezesUsed < maxFreezes {
				days[index].status = .freezed
				freezesUsed += 1
				lastActivityDate = Date()
			}
			saveStatus(for: days[index], actualDate: date(for: days[index]))
		}
	}
	
	func checkStreakExpiration() {
		guard let lastDate = lastActivityDate else { return }
		if Date().timeIntervalSince(lastDate) > maxInactivitySeconds {
			resetStreakData()
		}
	}
	
	func resetForNewGoal(newTopic: String, newTimeframe: String) {
		self.learningTopic = newTopic
		self.selectedTimeframe = newTimeframe
		self.days = ActivityViewModel.generateDays(for: newTimeframe)
		resetStreakData()
	}
	
	private func resetStreakData() {
		self.freezesUsed = 0
		self.lastActivityDate = nil
		for i in 0..<days.count {
			days[i].status = .empty
			saveStatus(for: days[i], actualDate: date(for: days[i]))
		}
		selectToday()
	}
	
	private func saveStatus(for day: DayActivity, actualDate: Date) {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let dateKey = formatter.string(from: actualDate)
		
		let statusString: String
		switch day.status {
		case .learned: statusString = "learned"
		case .freezed: statusString = "freezed"
		default: statusString = "empty"
		}
		UserDefaults.standard.set(statusString, forKey: "status_date_\(dateKey)")
	}
	
	private func loadSavedStatuses() {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		
		for i in 0..<days.count {
			let actualDate = date(for: days[i])
			let dateKey = formatter.string(from: actualDate)
			
			if let raw = UserDefaults.standard.string(forKey: "status_date_\(dateKey)") {
				switch raw {
				case "learned": days[i].status = .learned
				case "freezed": days[i].status = .freezed
				default: days[i].status = .empty
				}
			}
		}
	}
	
	// Exact date status lookup for the calendar view (prevents month bleeding)
	func status(for date: Date) -> ActivityStatus {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let dateKey = formatter.string(from: date)
		
		if let raw = UserDefaults.standard.string(forKey: "status_date_\(dateKey)") {
			switch raw {
			case "learned": return .learned
			case "freezed": return .freezed
			default: return .empty
			}
		}
		
		// Fallback check against dashboard days
		if let match = days.first(where: { Calendar.current.isDate(self.date(for: $0), inSameDayAs: date) }) {
			return match.status
		}
		return .empty
	}
}
