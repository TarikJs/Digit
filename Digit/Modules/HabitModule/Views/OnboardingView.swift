import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var onboardingHomeViewModel = HomeViewModel(
        habitService: HabitService(),
        progressService: HabitProgressService(),
        userId: UUID() // Replace with actual user ID if available
    )
    
    var body: some View {
        ZStack {
            Color.digitGrayLight
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
                        .foregroundStyle(Color.digitBrand)
                }
                .padding(.leading)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Title
                        Text(stepTitle)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.digitBrand)
                            .padding(.horizontal)
                        
                        // Step content
                        Group {
                            switch viewModel.currentStep {
                            case .name:
                                nameStep
                            case .userName:
                                usernameStep
                            case .email:
                                emailStep
                            case .dateOfBirth:
                                dateOfBirthStep
                            case .gender:
                                genderStep
                            case .enableNotification:
                                enableNotificationStep
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
                
                // Continue button (always shown)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.proceedToNextStep()
                    }
                }) {
                    Text(viewModel.currentStep == .enableNotification ? "Get Started" : "Continue")
                        .font(.system(size: 24))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.digitBrand)
                        .foregroundStyle(Color.white)
                        .cornerRadius(12)
                }
                .opacity(viewModel.canProceedToNextStep && !viewModel.isCheckingUserName ? 1.0 : 0.5)
                .disabled(!viewModel.canProceedToNextStep || viewModel.isCheckingUserName)
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
    private var stepTitle: String {
        switch viewModel.currentStep {
        case .name:
            return "What's your name?"
        case .userName:
            return "Choose a username"
        case .email:
            return "What's your email?"
        case .dateOfBirth:
            return "When's your birthday?"
        case .gender:
            return "What are your pronouns?"
        case .enableNotification:
            return "Enable notifications?"
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
                                .foregroundStyle(Color.secondary)
                        }
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.digitBrand, lineWidth: 1.7)
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
                                .foregroundStyle(Color.secondary)
                        }
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.digitBrand, lineWidth: 1.7)
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
    
    private var usernameStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Pick a unique username. This will be visible to others.")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                TextField("", text: $viewModel.userName)
                    .font(.system(size: 24))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.primary)
                    .placeholder(when: viewModel.userName.isEmpty) {
                        Text("your_username").foregroundStyle(Color.secondary)
                    }
                    .padding()
                    .frame(height: 56)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.digitBrand, lineWidth: 1.7)
                    )
            }
            .padding(.horizontal)
            if viewModel.isCheckingUserName {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Checking username...")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            if let error = viewModel.errorMessage, !error.isEmpty {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            } else if !viewModel.isUserNameValid && !viewModel.userName.isEmpty {
                Text("Usernames must be at least 3 characters, only letters, numbers, and underscores.")
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
    }
    
    private var emailStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("We'll use your email only to notify you about important changes to the app, such as policy updates. We will never use it for marketing or spam.")
                .font(.system(size: 16))
                .foregroundStyle(Color.secondary)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                TextField("", text: $viewModel.email)
                    .font(.system(size: 20))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.primary)
                    .placeholder(when: viewModel.email.isEmpty) {
                        Text("you@email.com")
                            .foregroundStyle(Color.secondary)
                    }
                    .padding()
                    .frame(height: 56)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.digitBrand, lineWidth: 1.7)
                    )
            }
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
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.digitBrand, lineWidth: 1.7)
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
                                .foregroundStyle(Color.digitBrand)
                        }
                    }
                    .padding()
                    .frame(height: 56)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.digitBrand, lineWidth: 1.7)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
    
    private var enableNotificationStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Stay on track by enabling reminders and notifications.")
                .font(.system(size: 16))
                .foregroundStyle(Color.secondary)
                .padding(.horizontal)
            Toggle(isOn: $viewModel.notificationsEnabled) {
                Text("Enable notifications")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.digitBrand))
            .padding(.horizontal)
        }
    }
}

#if DEBUG
#Preview {
    OnboardingView(viewModel: OnboardingViewModel(onComplete: {}, onDismiss: {}))
}
#endif 