import SwiftUI

extension CalendarProgressViewModel.HabitCalendarData: HabitCalendarDataProtocol {
    typealias Day = CalendarProgressViewModel.DayCompletion
}
extension CalendarProgressViewModel.DayCompletion: HabitCalendarDayProtocol {}

struct CalenderProgressView: View {
    @StateObject private var viewModel: CalendarProgressViewModel

    init(habitService: HabitServiceProtocol = HabitService(), progressService: HabitProgressServiceProtocol = HabitProgressService(), userId: UUID) {
        _viewModel = StateObject(wrappedValue: CalendarProgressViewModel(habitService: habitService, progressService: progressService, userId: userId))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.digitGrayLight
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Month at a Glance")
                            .font(.digitTitle2)
                            .foregroundStyle(Color.white)
                        Text("Showing your last 3 months of progress.")
                            .font(.digitBody)
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.digitBrand.edgesIgnoringSafeArea(.top))
                    .padding(.bottom, 16)
                    if viewModel.isLoading {
                        ProgressView().padding()
                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red).padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.habits) { habit in
                                    HabitCalendarCard(habit: habit)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
#Preview {
    CalenderProgressView(userId: UUID())
}
#endif 