import SwiftUI
import Combine

struct ActivityDashboardView: View {
	@ObservedObject var viewModel: ActivityViewModel
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.scenePhase) private var scenePhase
	@StateObject private var onboardingVM = OnboardingViewModel()
	@State private var showEditGoal: Bool = false
	@State private var selectedTimeframe: String = "Week"
	@State private var showCalendarView: Bool = false
	
	var body: some View {
		ZStack {
			(colorScheme == .dark ? Color.black : Color.white)
				.ignoresSafeArea()
			
			VStack(alignment: .leading, spacing: 20) {
				
				// Top Navigation Bar
				HStack {
					Text(viewModel.learningTopic)
						.font(.system(size: 32, weight: .bold))
						.foregroundColor(colorScheme == .dark ? .white : .black)
					
					Spacer()
					
					HStack(spacing: 12) {
						Button(action: { showCalendarView = true }) {
							Image(systemName: "calendar")
								.font(.system(size: 18))
								.foregroundColor(colorScheme == .dark ? .white : .black)
								.padding(10)
								.background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGray6))
								.clipShape(Circle())
						}
						
						Button(action: { showEditGoal = true }) {
							Image(systemName: "pencil")
								.font(.system(size: 18))
								.foregroundColor(colorScheme == .dark ? .white : .black)
								.padding(10)
								.background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGray6))
								.clipShape(Circle())
						}
					}
				}
				
				// Dynamic Current Date Header
				Text(viewModel.formattedCurrentDate)
					.font(.system(size: 14))
					.foregroundColor(.gray)
				
				// Scrollable Days Selector Row
				ScrollViewReader { proxy in
					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 12) {
							ForEach(viewModel.days) { day in
								VStack(spacing: 6) {
									Text(day.dayName)
										.font(.system(size: 12, weight: .medium))
										.foregroundColor(.gray)
									
									Text("\(day.dateNumber)")
										.font(.system(size: 15, weight: .semibold))
										.foregroundColor(dayTextColor(for: day))
										.frame(width: 36, height: 36)
										.background(dayBackground(for: day))
										.clipShape(Circle())
								}
								.id(day.id)
								.contentShape(Rectangle())
								.onTapGesture {
									viewModel.selectDay(id: day.id)
								}
							}
						}
						.padding(.vertical, 4)
					}
					.onAppear {
						proxy.scrollTo(viewModel.selectedDayId, anchor: .center)
					}
				}
				
				// Metric Cards
				HStack(spacing: 14) {
					VStack(spacing: 6) {
						Image(systemName: "flame.fill")
							.foregroundColor(.orange)
							.font(.system(size: 20))
						Text("\(viewModel.learnedDaysCount) \(viewModel.learnedDaysCount == 1 ? "day" : "days")")
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(colorScheme == .dark ? .white : .black)
						Text("Learned")
							.font(.system(size: 12))
							.foregroundColor(.gray)
					}
					.frame(maxWidth: .infinity)
					.padding(.vertical, 18)
					.background(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(.systemGray6))
					.cornerRadius(16)
					
					VStack(spacing: 6) {
						Image(systemName: "snowflake")
							.foregroundColor(.cyan)
							.font(.system(size: 20))
						Text("\(viewModel.freezedDaysCount) \(viewModel.freezedDaysCount == 1 ? "day" : "days")")
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(colorScheme == .dark ? .white : .black)
						Text("Freezed")
							.font(.system(size: 12))
							.foregroundColor(.gray)
					}
					.frame(maxWidth: .infinity)
					.padding(.vertical, 18)
					.background(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(.systemGray6))
					.cornerRadius(16)
				}
				
				Spacer()
				
				// MARK: - Dynamic Content (Active vs Learning Period Over)
				if viewModel.isLearningPeriodOver {
					VStack(spacing: 20) {
						Spacer()
						if viewModel.isGoalMet {
							VStack(spacing: 12) {
								Image(systemName: "hands.sparkles.fill")
									.font(.system(size: 54))
									.foregroundColor(.yellow)
								Text("Will done!")
									.font(.system(size: 22, weight: .bold))
									.foregroundColor(colorScheme == .dark ? .white : .black)
								Text("Ready for your next goal?")
									.font(.system(size: 14))
									.foregroundColor(.gray)
							}
						} else {
							VStack(spacing: 12) {
								ZStack {
									RoundedRectangle(cornerRadius: 14)
										.fill(Color.white)
										.frame(width: 52, height: 52)
									Image(systemName: "xmark.seal.fill")
										.font(.system(size: 40, weight: .bold))
										.foregroundColor(.orange)
								}
								Text("You didn't reach your goal this time.")
									.font(.system(size: 18, weight: .bold))
									.foregroundColor(colorScheme == .dark ? .white : .black)
								Text("Want to set another goal?")
									.font(.system(size: 14))
									.foregroundColor(.gray)
							}
						}
						Spacer()
						Button(action: { viewModel.showOnboarding = true }) {
							HStack(spacing: 8) {
								Image(systemName: "pencil")
									.font(.system(size: 16, weight: .semibold))
								Text("Set a goal")
									.font(.system(size: 16, weight: .semibold))
							}
							.foregroundColor(.white)
							.frame(maxWidth: .infinity)
							.padding(.vertical, 16)
							.background(Color.orange)
							.cornerRadius(28)
						}
						.padding(.bottom, 10)
					}
				} else {
					// Active Learning Period Controls
					VStack {
						Spacer()
						HStack {
							Spacer()
							Button(action: { viewModel.toggleLogStatus() }) {
								ZStack {
									Circle()
										.fill(mainButtonBackground)
										.frame(width: 210, height: 210)
										.shadow(color: viewModel.selectedDay.status == .empty ? Color.orange.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
									Text(viewModel.mainButtonText)
										.font(.system(size: 18, weight: .bold))
										.foregroundColor(.white)
								}
							}
							.disabled(viewModel.isMainButtonDisabled)
							Spacer()
						}
						Spacer()
					}
					
					// Bottom Freeze Action Button & Counter
					VStack(spacing: 8) {
						Button(action: { viewModel.freezeDay() }) {
							Text(viewModel.freezeButtonText)
								.font(.system(size: 15, weight: .semibold))
								.foregroundColor(freezeButtonTextColor)
								.frame(maxWidth: .infinity)
								.padding(.vertical, 16)
								.background(freezeButtonBackground)
								.cornerRadius(28)
						}
						.disabled(viewModel.isFreezeButtonDisabled)
						
						Text("\(viewModel.freezesUsed) out of \(viewModel.maxFreezes) Freezes used")
							.font(.system(size: 12))
							.foregroundColor(.gray)
					}
					.padding(.bottom, 10)
				}
			}
			.padding(.horizontal, 24)
		}
		.onAppear { viewModel.checkStreakExpiration() }
		.onChange(of: scenePhase) { _, newPhase in
			if newPhase == .active { viewModel.checkStreakExpiration() }
		}
		.fullScreenCover(isPresented: $viewModel.showOnboarding) {
			OnboardingView(viewModel: onboardingVM)
				.onChange(of: onboardingVM.isStarted) { _, isStarted in
					if isStarted {
						viewModel.resetForNewGoal(newTopic: onboardingVM.learningTopic, newTimeframe: onboardingVM.selectedTimeframe)
						viewModel.showOnboarding = false
						onboardingVM.learningTopic = ""
						onboardingVM.isStarted = false
					}
				}
		}
		.fullScreenCover(isPresented: $showEditGoal) {
			EditGoalView(
				learningTopic: $viewModel.learningTopic,
				selectedTimeframe: $selectedTimeframe
			) {
				viewModel.resetForNewGoal(newTopic: viewModel.learningTopic, newTimeframe: selectedTimeframe)
			}
		}
		.fullScreenCover(isPresented: $showCalendarView) {
			ActivitiesCalendarView(viewModel: viewModel)
		}
	}
	
	// MARK: - View Helpers
	func dayTextColor(for day: DayActivity) -> Color {
		if day.id == viewModel.selectedDayId { return .white }
		switch day.status {
		case .learned: return .orange
		case .freezed: return .cyan
		case .empty: return colorScheme == .dark ? .gray : .primary
		}
	}
	
	func dayBackground(for day: DayActivity) -> Color {
		if day.id == viewModel.selectedDayId { return .orange }
		switch day.status {
		case .learned: return Color.orange.opacity(0.25) // Low opacity orange circle
		case .freezed: return Color.cyan.opacity(0.25)   // Low opacity blue circle
		case .empty: return Color.clear
		}
	}
	
	var mainButtonBackground: Color {
		switch viewModel.selectedDay.status {
		case .learned, .freezed: return Color(red: 0.15, green: 0.15, blue: 0.15)
		case .empty: return Color.orange
		}
	}
	
	var freezeButtonTextColor: Color {
		if viewModel.selectedDay.status == .freezed || viewModel.freezesUsed >= viewModel.maxFreezes || viewModel.selectedDay.status == .learned {
			return .gray
		} else { return .white }
	}
	
	var freezeButtonBackground: Color {
		if viewModel.selectedDay.status == .freezed || viewModel.freezesUsed >= viewModel.maxFreezes || viewModel.selectedDay.status == .learned {
			return colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGray5)
		} else { return Color.cyan }
	}
}
