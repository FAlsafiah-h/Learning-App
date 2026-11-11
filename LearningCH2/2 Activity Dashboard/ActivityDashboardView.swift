import SwiftUI
import Combine

// MARK: - View
struct ActivityDashboardView: View {
	@ObservedObject var viewModel: ActivityViewModel
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		ZStack {
			(colorScheme == .dark ? Color.black : Color.white)
				.ignoresSafeArea()
			
			VStack(alignment: .leading, spacing: 20) {
				
				// Top Navigation Bar (Displays custom skill topic)
				HStack {
					Text(viewModel.learningTopic)
						.font(.system(size: 32, weight: .bold))
						.foregroundColor(colorScheme == .dark ? .white : .black)
					
					Spacer()
					
					HStack(spacing: 12) {
						Button(action: {}) {
							Image(systemName: "calendar")
								.font(.system(size: 18))
								.foregroundColor(colorScheme == .dark ? .white : .black)
								.padding(10)
								.background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGray6))
								.clipShape(Circle())
						}
						
						Button(action: {}) {
							Image(systemName: "pencil")
								.font(.system(size: 18))
								.foregroundColor(colorScheme == .dark ? .white : .black)
								.padding(10)
								.background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGray6))
								.clipShape(Circle())
						}
					}
				}
				
				Text("Thursday, 24 October")
					.font(.system(size: 14))
					.foregroundColor(.gray)
				
				// Weekly Date Selector Row
				HStack(spacing: 0) {
					ForEach(viewModel.weekDays) { day in
						VStack(spacing: 6) {
							Text(day.dayName)
								.font(.system(size: 12, weight: .medium))
								.foregroundColor(.gray)
							
							Text("\(day.dateNumber)")
								.font(.system(size: 15, weight: .semibold))
								.foregroundColor(dayColor(for: day))
								.frame(width: 36, height: 36)
								.background(dayBackground(for: day))
								.clipShape(Circle())
						}
						.frame(maxWidth: .infinity)
						.contentShape(Rectangle())
						.onTapGesture {
							viewModel.selectDay(id: day.id)
						}
					}
				}
				.padding(.vertical, 4)
				
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
				
				// Main Log Action Button
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button(action: {
							viewModel.toggleLogStatus()
						}) {
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
					Button(action: {
						viewModel.freezeDay()
					}) {
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
			.padding(.horizontal, 24)
		}
	}
	
	// MARK: - View Helper Functions & Computed Presentation Properties
	
	func dayColor(for day: DayActivity) -> Color {
		if day.id == viewModel.selectedDayId {
			return .white
		}
		switch day.status {
		case .learned:
			return .orange
		case .freezed:
			return .cyan
		case .empty:
			return colorScheme == .dark ? .gray : .primary
		}
	}
	
	func dayBackground(for day: DayActivity) -> Color {
		if day.id == viewModel.selectedDayId {
			return .orange
		}
		return Color.clear
	}
	
	var mainButtonBackground: Color {
		switch viewModel.selectedDay.status {
		case .learned, .freezed:
			return Color(red: 0.15, green: 0.15, blue: 0.15)
		case .empty:
			return Color.orange
		}
	}
	
	var freezeButtonTextColor: Color {
		if viewModel.selectedDay.status == .freezed || viewModel.freezesUsed >= viewModel.maxFreezes || viewModel.selectedDay.status == .learned {
			return .gray
		} else {
			return .white
		}
	}
	
	var freezeButtonBackground: Color {
		if viewModel.selectedDay.status == .freezed || viewModel.freezesUsed >= viewModel.maxFreezes || viewModel.selectedDay.status == .learned {
			return colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGray5)
		} else {
			return Color.cyan
		}
	}
}

// MARK: - Previews
#Preview("Dark Mode") {
	ActivityDashboardView(viewModel: ActivityViewModel(learningTopic: "Swift"))
		.preferredColorScheme(.dark)
}

#Preview("Light Mode") {
	ActivityDashboardView(viewModel: ActivityViewModel(learningTopic: "Swift"))
		.preferredColorScheme(.light)
}
