import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.digitBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 32) {
                // Back button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.goBack()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.brand)
                }
                .padding(.leading)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Title
                        Text(stepTitle)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.brand)
                            .padding(.horizontal)
                        
                        // Step content
                        Group {
                            switch viewModel.currentStep {
                            case .name:
                                nameStep
                            case .dateOfBirth:
                                dateOfBirthStep
                            case .gender:
                                genderStep
                            case .habitGoal:
                                habitGoalStep
                            case .habitTime:
                                habitTimeStep
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
                
                // Continue button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.proceedToNextStep()
                    }
                }) {
                    Text(viewModel.currentStep == .habitTime ? "Get Started" : "Continue")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.canProceedToNextStep ? Color.brand : Color.brand.opacity(0.5))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(!viewModel.canProceedToNextStep)
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
    private var stepTitle: String {
        switch viewModel.currentStep {
        case .name:
            return "What's your name?"
        case .dateOfBirth:
            return "When's your birthday?"
        case .gender:
            return "What are your pronouns?"
        case .habitGoal:
            return "What's your main goal?"
        case .habitTime:
            return "When do you prefer to build habits?"
        }
    }
    
    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Let's personalize your habit-building journey.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // First Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                    TextField("", text: $viewModel.firstName)
                        .font(.system(size: 24))
                        .placeholder(when: viewModel.firstName.isEmpty) {
                            Text("Your first name")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(height: 56)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.brand, lineWidth: 1.7)
                        )
                }
                
                // Last Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                    TextField("", text: $viewModel.lastName)
                        .font(.system(size: 24))
                        .placeholder(when: viewModel.lastName.isEmpty) {
                            Text("Your last name")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(height: 56)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.brand, lineWidth: 1.7)
                        )
                }
            }
            .padding(.horizontal)
            
            Text("Your last name will only be shown as an initial.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var dateOfBirthStep: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("You must be at least 18 years old to use Digit.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            DatePicker(
                "",
                selection: $viewModel.dateOfBirth,
                in: viewModel.dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .padding()
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brand, lineWidth: 1.7)
            )
            .padding(.horizontal)
        }
    }
    
    private var genderStep: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select your pronouns")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            ForEach(Gender.allCases, id: \.self) { gender in
                Button(action: {
                    withAnimation {
                        viewModel.selectedGender = gender
                    }
                }) {
                    HStack {
                        Text(gender.rawValue)
                            .font(.system(size: 24))
                        Spacer()
                        if viewModel.selectedGender == gender {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(Color.brand)
                        }
                    }
                    .padding()
                    .frame(height: 56)
                    .background(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brand, lineWidth: 1.7)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
    
    private var habitGoalStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("This will help us personalize your habit-building experience.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("", text: $viewModel.habitGoal)
                    .font(.system(size: 24))
                    .placeholder(when: viewModel.habitGoal.isEmpty) {
                        Text("e.g., Exercise more regularly")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(height: 56)
                    .background(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brand, lineWidth: 1.7)
                    )
            }
            .padding(.horizontal)
            
            Text("You can always add more goals later.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var habitTimeStep: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose when you're most likely to stick to your habits.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            ForEach(PreferredHabitTime.allCases, id: \.self) { time in
                Button(action: {
                    withAnimation {
                        viewModel.selectedHabitTime = time
                    }
                }) {
                    HStack {
                        Text(time.rawValue)
                            .font(.system(size: 24))
                        Spacer()
                        if viewModel.selectedHabitTime == time {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(Color.brand)
                        }
                    }
                    .padding()
                    .frame(height: 56)
                    .background(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brand, lineWidth: 1.7)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
}

#if DEBUG
#Preview {
    OnboardingView(viewModel: OnboardingViewModel(onComplete: {}, onDismiss: {}))
}
#endif 