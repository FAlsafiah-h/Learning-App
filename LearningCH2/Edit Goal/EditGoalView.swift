//
//  EditGoalView.swift
//  LearningCH2
//
//  Created by Fatemah Alsafiah on 15/11/2026.
//


import SwiftUI

struct EditGoalView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorScheme) var colorScheme
	
	@Binding var learningTopic: String
	@Binding var selectedTimeframe: String
	
	let timeframes = ["Week", "Month", "Year"]
	
	@State private var tempTopic: String = ""
	@State private var tempTimeframe: String = "Week"
	@State private var showAlert: Bool = false
	var onUpdate: (() -> Void)?
	
	var body: some View {
		ZStack {
			(colorScheme == .dark ? Color.black : Color.white)
				.ignoresSafeArea()
			
			VStack(alignment: .leading, spacing: 28) {
				
				// Top Navigation Bar
				HStack {
					Button(action: { dismiss() }) {
						Image(systemName: "chevron.left")
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(colorScheme == .dark ? .white : .black)
							.padding(10)
							.background(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : Color(.systemGray6))
							.clipShape(Circle())
					}
					
					Spacer()
					
					Text("Learning Goal")
						.font(.system(size: 17, weight: .semibold))
						.foregroundColor(colorScheme == .dark ? .white : .black)
					
					Spacer()
					
					Button(action: {
						showAlert = true
					}) {
						Image(systemName: "checkmark")
							.font(.system(size: 16, weight: .bold))
							.foregroundColor(.white)
							.padding(10)
							.background(Color.orange)
							.clipShape(Circle())
					}
				}
				.padding(.top, 10)
				
				// Topic Input Section
				VStack(alignment: .leading, spacing: 10) {
					Text("I want to learn")
						.font(.system(size: 15))
						.foregroundColor(.gray)
					
					TextField("", text: $tempTopic, prompt: Text("Swift").foregroundColor(.gray))
						.font(.system(size: 16))
						.foregroundColor(colorScheme == .dark ? .white : .black)
						.padding(.bottom, 8)
					
					Rectangle()
						.frame(height: 1)
						.foregroundColor(Color.gray.opacity(0.3))
				}
				.padding(.top, 10)
				
				// Timeframe Selection Section
				VStack(alignment: .leading, spacing: 14) {
					Text("I want to learn it in a")
						.font(.system(size: 15))
						.foregroundColor(.gray)
					
					HStack(spacing: 12) {
						ForEach(timeframes, id: \.self) { timeframe in
							Button(action: {
								tempTimeframe = timeframe
							}) {
								Text(timeframe)
									.font(.system(size: 15, weight: .medium))
									.foregroundColor(tempTimeframe == timeframe ? .white : (colorScheme == .dark ? .gray : .primary))
									.frame(maxWidth: .infinity)
									.padding(.vertical, 14)
									.background(
										RoundedRectangle(cornerRadius: 20)
											.fill(
												tempTimeframe == timeframe
												? Color.orange
												: (colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color(.systemGray6))
											)
									)
							}
						}
					}
				}
				
				Spacer()
			}
			.padding(.horizontal, 24)
			
			// Custom Confirmation Alert Overlay
			if showAlert {
				ZStack {
					Color.black.opacity(0.5)
						.ignoresSafeArea()
						.onTapGesture { showAlert = false }
					
					VStack(alignment: .leading, spacing: 16) {
						Text("Update goal")
							.font(.system(size: 18, weight: .bold))
							.foregroundColor(colorScheme == .dark ? .white : .black)
						
						Text("If you update now, your streak will start over.")
							.font(.system(size: 14))
							.foregroundColor(.gray)
						
						HStack(spacing: 12) {
							Button(action: {
								showAlert = false
							}) {
								Text("Dismiss")
									.font(.system(size: 15, weight: .semibold))
									.foregroundColor(colorScheme == .dark ? .white : .black)
									.frame(maxWidth: .infinity)
									.padding(.vertical, 14)
									.background(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(.systemGray5))
									.cornerRadius(24)
							}
							
							Button(action: {
								learningTopic = tempTopic.isEmpty ? learningTopic : tempTopic
								selectedTimeframe = tempTimeframe
								showAlert = false
								onUpdate?()
								dismiss()
							}) {
								Text("Update")
									.font(.system(size: 15, weight: .semibold))
									.foregroundColor(.white)
									.frame(maxWidth: .infinity)
									.padding(.vertical, 14)
									.background(Color.orange)
									.cornerRadius(24)
							}
						}
					}
					.padding(24)
					.background(colorScheme == .dark ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color.white)
					.cornerRadius(24)
					.shadow(radius: 20)
					.padding(.horizontal, 32)
				}
			}
		}
		.onAppear {
			tempTopic = learningTopic
			tempTimeframe = selectedTimeframe
		}
		.navigationBarHidden(true)
	}
}