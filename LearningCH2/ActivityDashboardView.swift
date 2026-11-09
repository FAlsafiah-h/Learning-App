import SwiftUI
import Combine

// MARK: - Models
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

// MARK: - ViewModel
class ActivityViewModel: ObservableObject {
	@Published var weekDays: [DayActivity] = [
		DayActivity(id: 0, dayName: "S", dateNumber: 20, status: .learned),
		DayActivity(id: 1, dayName: "M", dateNumber: 21, status: .learned),
		DayActivity(id: 2, dayName: "T", dateNumber: 22, status: .learned),
		DayActivity(id: 3, dayName: "W", dateNumber: 23, status: .empty),
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

// MARK: - View
struct ActivityDashboardView: View {
	@StateObject private var viewModel = ActivityViewModel()
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		ZStack {
			(colorScheme == .dark ? Color.black : Color.white)
				.ignoresSafeArea()
			
			VStack(alignment: .leading, spacing: 20) {
				
				// Top Navigation Bar
				HStack {
					Text("Activity")
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
								
								Text(mainButtonText)
									.font(.system(size: 18, weight: .bold))
									.foregroundColor(.white)
							}
						}
						.disabled(viewModel.selectedDay.status == .freezed)
						Spacer()
					}
					Spacer()
				}
				
				// Bottom Freeze Action Button & Counter
				VStack(spacing: 8) {
					Button(action: {
						viewModel.freezeDay()
					}) {
						Text(freezeButtonText)
							.font(.system(size: 15, weight: .semibold))
							.foregroundColor(freezeButtonTextColor)
							.frame(maxWidth: .infinity)
							.padding(.vertical, 16)
							.background(freezeButtonBackground)
							.cornerRadius(28)
					}
					.disabled(viewModel.freezesUsed >= viewModel.maxFreezes || viewModel.selectedDay.status != .empty)
					
					Text("\(viewModel.freezesUsed) out of \(viewModel.maxFreezes) Freezes used")
						.font(.system(size: 12))
						.foregroundColor(.gray)
				}
				.padding(.bottom, 10)
			}
			.padding(.horizontal, 24)
		}
	}
	
	// MARK: - View Helper Functions & Computed Properties
	
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
		case .learned:
			return Color(red: 0.15, green: 0.15, blue: 0.15)
		case .freezed:
			return Color(red: 0.15, green: 0.15, blue: 0.15)
		case .empty:
			return Color.orange
		}
	}
	
	var mainButtonText: String {
		switch viewModel.selectedDay.status {
		case .learned:
			return "Logged as Learned"
		case .freezed:
			return "Day Freezed"
		case .empty:
			return "Log as Learned"
		}
	}
	
	var freezeButtonText: String {
		if viewModel.selectedDay.status == .learned {
			return "Day logged as learned"
		} else if viewModel.selectedDay.status == .freezed {
			return "Freezed for a day"
		} else if viewModel.freezesUsed >= viewModel.maxFreezes {
			return "Out of freezes"
		} else {
			return "Freeze for a day"
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
	ActivityDashboardView()
		.preferredColorScheme(.dark)
}

#Preview("Light Mode") {
	ActivityDashboardView()
		.preferredColorScheme(.light)
}
