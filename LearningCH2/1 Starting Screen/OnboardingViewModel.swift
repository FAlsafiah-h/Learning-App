import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
	@Published var learningTopic: String = ""
	@Published var selectedTimeframe: String = "Week"
	@Published var isStarted: Bool = false
	
	let timeframes = ["Week", "Month", "Year"]
	
	func startLearning() {
		if learningTopic.trimmingCharacters(in: .whitespaces).isEmpty {
			learningTopic = "Activity" // Fallback default
		}
		isStarted = true
	}
}
