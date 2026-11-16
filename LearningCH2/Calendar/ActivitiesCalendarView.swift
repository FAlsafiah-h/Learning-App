import SwiftUI

struct ActivitiesCalendarView: View {
	@ObservedObject var viewModel: ActivityViewModel
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		ZStack {
			(colorScheme == .dark ? Color.black : Color.white)
				.ignoresSafeArea()
			
			VStack(alignment: .leading, spacing: 0) {
				
				// Top Navigation Bar with Glass Effect
				HStack {
					Button(action: { dismiss() }) {
						Image(systemName: "chevron.left")
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(colorScheme == .dark ? .white : .black)
							.padding(10)
							.background(.ultraThinMaterial) // Glass Effect
							.clipShape(Circle())
					}
					
					Spacer()
					
					Text("Activities")
						.font(.system(size: 17, weight: .semibold))
						.foregroundColor(colorScheme == .dark ? .white : .black)
					
					Spacer()
					
					Circle()
						.fill(Color.clear)
						.frame(width: 36, height: 36)
				}
				.padding(.horizontal, 24)
				.padding(.top, 10)
				.padding(.bottom, 20)
				
				// Scrollable Calendar Months Grid
				ScrollView(showsIndicators: false) {
					LazyVStack(alignment: .leading, spacing: 32) {
						ForEach(generateMonthsForCurrentYear(), id: \.self) { monthDate in
							DynamicMonthGridView(date: monthDate, viewModel: viewModel)
						}
					}
					.padding(.horizontal, 24)
					.padding(.bottom, 40)
				}
			}
		}
		.navigationBarHidden(true)
	}
	
	func generateMonthsForCurrentYear() -> [Date] {
		let calendar = Calendar.current
		let currentDate = Date()
		
		guard let yearInterval = calendar.dateInterval(of: .year, for: currentDate) else {
			return [currentDate]
		}
		
		var months: [Date] = []
		var tempDate = yearInterval.start
		
		while tempDate < yearInterval.end {
			months.append(tempDate)
			if let nextMonth = calendar.date(byAdding: .month, value: 1, to: tempDate) {
				tempDate = nextMonth
			} else {
				break
			}
		}
		return months
	}
}

struct DynamicMonthGridView: View {
	@Environment(\.colorScheme) var colorScheme
	let date: Date
	@ObservedObject var viewModel: ActivityViewModel
	
	let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
	let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
	
	var body: some View {
		let calendar = Calendar.current
		let monthName = monthYearString(for: date)
		let days = daysInMonth(for: date)
		let startOffset = startingWeekdayOffset(for: date)
		
		return VStack(alignment: .leading, spacing: 14) {
			Text(monthName)
				.font(.system(size: 16, weight: .bold))
				.foregroundColor(colorScheme == .dark ? .white : .black)
			
			// Weekday Headers
			LazyVGrid(columns: columns, spacing: 10) {
				ForEach(weekdays, id: \.self) { day in
					Text(day)
						.font(.system(size: 10, weight: .semibold))
						.foregroundColor(.gray)
						.frame(maxWidth: .infinity)
				}
			}
			
			// Days Grid
			LazyVGrid(columns: columns, spacing: 12) {
				ForEach(0..<startOffset, id: \.self) { _ in
					Text("")
						.frame(height: 32)
				}
				
				ForEach(days, id: \.self) { dayNumber in
					let dayDate = dateForDayNumber(dayNumber, in: date)
					let status = viewModel.status(for: dayDate)
					let isToday = calendar.isDate(dayDate, inSameDayAs: Date())
					
					Text("\(dayNumber)")
						.font(.system(size: 14, weight: isToday ? .bold : .medium))
						.foregroundColor(dayTextColor(status: status, isToday: isToday))
						.frame(width: 32, height: 32)
						.background(dayBackground(status: status, isToday: isToday))
						.clipShape(Circle())
				}
			}
		}
	}
	
	private func monthYearString(for date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM yyyy"
		return formatter.string(from: date)
	}
	
	private func daysInMonth(for date: Date) -> [Int] {
		let calendar = Calendar.current
		guard let range = calendar.range(of: .day, in: .month, for: date) else {
			return []
		}
		return Array(range)
	}
	
	private func startingWeekdayOffset(for date: Date) -> Int {
		let calendar = Calendar.current
		guard let range = calendar.dateInterval(of: .month, for: date) else {
			return 0
		}
		let weekday = calendar.component(.weekday, from: range.start)
		return weekday - 1
	}
	
	private func dateForDayNumber(_ day: Int, in monthDate: Date) -> Date {
		var components = Calendar.current.dateComponents([.year, .month], from: monthDate)
		components.day = day
		return Calendar.current.date(from: components) ?? monthDate
	}
	
	private func dayTextColor(status: ActivityStatus, isToday: Bool) -> Color {
		if status == .learned { return .orange }
		if status == .freezed { return .cyan }
		if isToday { return .white }
		return colorScheme == .dark ? Color.gray.opacity(0.8) : Color.primary.opacity(0.8)
	}
	
	private func dayBackground(status: ActivityStatus, isToday: Bool) -> Color {
		if status == .learned {
			return Color.orange.opacity(0.25)
		} else if status == .freezed {
			return Color.cyan.opacity(0.25)
		} else if isToday {
			return Color.orange
		}
		return Color.clear
	}
}
