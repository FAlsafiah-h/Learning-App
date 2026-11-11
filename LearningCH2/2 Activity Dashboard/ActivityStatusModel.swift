import SwiftUI
import Combine

// MARK: - Model

enum ActivityStatus {
	case empty
	case learned
	case freezed
}

struct DayActivity: Identifiable {
	let id: Int
	let dayName: String
	let dateNumber: Int
	var status: ActivityStatus
}

