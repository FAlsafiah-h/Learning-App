import SwiftUI
import Combine

class ActivityViewModel: ObservableObject {
	@Published var learningTopic: String
	
	// Accept the topic during initialization
	init(learningTopic: String) {
		self.learningTopic = learningTopic
	}
	
	@Published var weekDays: [DayActivity] = [
		DayActivity(id: 0, dayName: "S", dateNumber: 20, status: .learned),
		DayActivity(id: 1, dayName: "M", dateNumber: 21, status: .learned),
		DayActivity(id: 2, dayName: "T", dateNumber: 22, status: .learned),
		DayActivity(id: 3, dayName: "W", dateNumber: 23, status: .learned),
		DayActivity(id: 4, dayName: "T", dateNumber: 24, status: .empty),
		DayActivity(id: 5, dayName: "F", dateNumber: 25, status: .empty),
		DayActivity(id: 6, dayName: "S", dateNumber: 26, status: .empty)
	]
	
	@Published var selectedDayId: Int = 4
	@Published var freezesUsed: Int = 0
	let maxFreezes: Int = 2

	var learnedDaysCount: Int {
		weekDays.filter { $0.status == .learned }.count
	}
	
	var freezedDaysCount: Int {
		weekDays.filter { $0.status == .freezed }.count
	}
	
	var selectedDay: DayActivity {
		weekDays.first(where: { $0.id == selectedDayId }) ?? weekDays[4]
	}
	
	var mainButtonText: String {
		switch selectedDay.status {
		case .learned:
			return "Logged as Learned"
		case .freezed:
			return "Day Freezed"
		case .empty:
			return "Log as Learned"
		}
	}
	
	var freezeButtonText: String {
		if selectedDay.status == .learned {
			return "Day logged as learned"
		} else if selectedDay.status == .freezed {
			return "Freezed for a day"
		} else if freezesUsed >= maxFreezes {
			return "Out of freezes"
		} else {
			return "Freeze for a day"
		}
	}
	
	var isMainButtonDisabled: Bool {
		return selectedDay.status == .freezed
	}
	
	var isFreezeButtonDisabled: Bool {
		return freezesUsed >= maxFreezes || selectedDay.status != .empty
	}
	
	func selectDay(id: Int) {
		selectedDayId = id
	}
	
	func toggleLogStatus() {
		if let index = weekDays.firstIndex(where: { $0.id == selectedDayId }) {
			if weekDays[index].status == .learned {
				weekDays[index].status = .empty
			} else if weekDays[index].status == .empty {
				weekDays[index].status = .learned
			}
		}
	}
	
	func freezeDay() {
		if let index = weekDays.firstIndex(where: { $0.id == selectedDayId }) {
			if weekDays[index].status == .empty && freezesUsed < maxFreezes {
				weekDays[index].status = .freezed
				freezesUsed += 1
			}
		}
	}
}
