import SwiftUI

@main
struct LearningApp: App {
	var body: some Scene {
		WindowGroup {
			RootView()
				.preferredColorScheme(.dark) 
		}
	}
	
	
	struct RootView: View {
		@StateObject private var onboardingVM = OnboardingViewModel()
		
		var body: some View {
			if onboardingVM.isStarted {
				ActivityDashboardView(
					viewModel: ActivityViewModel(
						learningTopic: onboardingVM.learningTopic,
						selectedTimeframe: onboardingVM.selectedTimeframe
					)
				)
			} else {
				OnboardingView(viewModel: onboardingVM)
			}
		}
	}
}
