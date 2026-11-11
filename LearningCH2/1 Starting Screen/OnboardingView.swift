import SwiftUI
import Combine

// MARK: - View
struct OnboardingView: View {
	@ObservedObject var viewModel: OnboardingViewModel
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		ZStack {
			(colorScheme == .dark ? Color.black : Color.white)
				.ignoresSafeArea()
			
			VStack(alignment: .leading, spacing: 28) {
				
				// Top Flame Icon
				HStack {
					Spacer()
					Image(systemName: "flame.fill")
						.font(.system(size: 38))
						.foregroundColor(.orange)
					Spacer()
				}
				.padding(.top, 10)
				
				// Header Greeting
				VStack(alignment: .leading, spacing: 6) {
					Text("Hello Learner")
						.font(.system(size: 34, weight: .bold))
						.foregroundColor(colorScheme == .dark ? .white : .black)
					
					Text("This app will help you learn everyday!")
						.font(.system(size: 15))
						.foregroundColor(.gray)
				}
				
				// Topic Input Section
				VStack(alignment: .leading, spacing: 10) {
					Text("I want to learn")
						.font(.system(size: 15))
						.foregroundColor(colorScheme == .dark ? .white : .black)
					
					TextField("", text: $viewModel.learningTopic, prompt: Text("Swift").foregroundColor(.gray))
						.font(.system(size: 16))
						.foregroundColor(colorScheme == .dark ? .white : .black)
						.padding(.bottom, 8)
					
					Rectangle()
						.frame(height: 1)
						.foregroundColor(Color.gray.opacity(0.4))
				}
				.padding(.top, 10)
				
				// Timeframe Selection Section
				VStack(alignment: .leading, spacing: 14) {
					Text("I want to learn it in a")
						.font(.system(size: 15))
						.foregroundColor(colorScheme == .dark ? .white : .black)
					
					HStack(spacing: 12) {
						ForEach(viewModel.timeframes, id: \.self) { timeframe in
							Button(action: {
								viewModel.selectedTimeframe = timeframe
							}) {
								Text(timeframe)
									.font(.system(size: 15, weight: .medium))
									.foregroundColor(viewModel.selectedTimeframe == timeframe ? .white : (colorScheme == .dark ? .gray : .primary))
									.frame(maxWidth: .infinity)
									.padding(.vertical, 14)
									.background(
										RoundedRectangle(cornerRadius: 20)
											.fill(
												viewModel.selectedTimeframe == timeframe
												? Color.orange
												: (colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(.systemGray6))
											)
									)
							}
						}
					}
				}
				
				Spacer()
				
				// Bottom Button & Footer Text
				VStack(spacing: 12) {
					Button(action: {
						viewModel.startLearning()
					}) {
						Text("Start Learning")
							.font(.system(size: 16, weight: .semibold))
							.foregroundColor(.white)
							.frame(maxWidth: .infinity)
							.padding(.vertical, 16)
							.background(Color.orange)
							.cornerRadius(28)
					}
					
					Text("You can edit your desire later")
						.font(.system(size: 12))
						.foregroundColor(.gray)
				}
				.padding(.bottom, 10)
			}
			.padding(.horizontal, 24)
		}
	}
}


struct RootView: View {
	@StateObject private var onboardingVM = OnboardingViewModel()
	
	var body: some View {
		if onboardingVM.isStarted {
			ActivityDashboardView(viewModel: ActivityViewModel(learningTopic: onboardingVM.learningTopic))
		} else {
			OnboardingView(viewModel: onboardingVM)
		}
	}
}

#Preview("Dark") {
	RootView()
		.preferredColorScheme(.dark)
}

#Preview("Light") {
	RootView()
		.preferredColorScheme(.light)
}
