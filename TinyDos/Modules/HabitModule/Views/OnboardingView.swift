import SwiftUI
import Combine

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var onboardingHomeViewModel = HomeViewModel(habitRepository: HabitRepository(), progressRepository: ProgressRepository(), userId: UUID())
    @State private var didAutoCheckVerification = false
    @State private var isCheckingVerification = false
    
    var body: some View {
        ZStack {
            Color.digitBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Back button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.goBack()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.plusJakartaSans(size: 17, weight: .medium))
                        .foregroundStyle(Color.digitBrand)
                        .accessibilityLabel("Back")
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        Text(stepTitle)
                            .font(.plusJakartaSans(size: 24, weight: .bold))
                            .foregroundStyle(Color.digitBrand)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        // Step content
                        Group {
                            switch viewModel.currentStep {
                            case .name:
                                nameStep
                            case .userName:
                                usernameStep
                            case .email:
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("What's your email?")
                                        .font(.plusJakartaSans(size: 16))
                                        .foregroundStyle(.secondary)
                                    TextField("Email address", text: $viewModel.email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .padding(.horizontal, 16)
                                        .frame(height: 56)
                                        .background(Color.digitGrayLight)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            case .dateOfBirth:
                                dateOfBirthStep
                            case .gender:
                                genderStep
                            case .region:
                                regionStep
                            case .enableNotification:
                                enableNotificationStep
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    .padding(.horizontal)
                }
                .scrollDismissesKeyboard(.immediately)
                
                // Continue button (always shown)
                VStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.proceedToNextStep()
                        }
                    }) {
                        Text(viewModel.currentStep == .enableNotification ? "Get Started" : "Continue")
                            .font(.plusJakartaSans(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.digitAccentRed)
                            .foregroundStyle(Color.white)
                            .cornerRadius(10)
                            .accessibilityLabel(viewModel.currentStep == .enableNotification ? "Get Started" : "Continue")
                    }
                    .opacity(viewModel.canProceedToNextStep && !viewModel.isCheckingUserName ? 1.0 : 0.5)
                    .disabled(!viewModel.canProceedToNextStep || viewModel.isCheckingUserName)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(Color.digitBackground)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard)
        .onChange(of: scenePhase) { newPhase in
            guard viewModel.currentStep == .email else { return }
            if newPhase == .active {
                // Wait 2 seconds, then check verification
                didAutoCheckVerification = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // Only check if still on email step and not already checked
                    if viewModel.currentStep == .email && !didAutoCheckVerification {
                        didAutoCheckVerification = true
                        Task { await viewModel.refreshEmailVerificationStatus() }
                    }
                }
            }
        }
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
        case .region:
            return "Select your region"
        case .enableNotification:
            return "Enable notifications?"
        }
    }
    
    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Let's personalize your habit-building journey.")
                    .font(.plusJakartaSans(size: 16))
                    .foregroundStyle(.secondary)
                Text("Your last name will only be shown as an initial.")
                    .font(.plusJakartaSans(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                // First Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.plusJakartaSans(size: 14))
                        .foregroundStyle(.secondary)
                    
                    TextField("", text: $viewModel.firstName)
                        .font(.plusJakartaSans(size: 17))
                        .placeholder(when: viewModel.firstName.isEmpty) {
                            Text("Your first name")
                                .font(.plusJakartaSans(size: 17))
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(Color.digitGrayLight)
                        .cornerRadius(10)
                }
                
                // Last Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(.plusJakartaSans(size: 14))
                        .foregroundStyle(.secondary)
                    
                    TextField("", text: $viewModel.lastName)
                        .font(.plusJakartaSans(size: 17))
                        .placeholder(when: viewModel.lastName.isEmpty) {
                            Text("Your last name")
                                .font(.plusJakartaSans(size: 17))
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(Color.digitGrayLight)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var usernameStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Pick a unique username. This will be visible to others.")
                .font(.plusJakartaSans(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                Text("Username")
                    .font(.plusJakartaSans(size: 14))
                    .foregroundStyle(.secondary)
                TextField("", text: $viewModel.userName)
                    .font(.plusJakartaSans(size: 17))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.primary)
                    .placeholder(when: viewModel.userName.isEmpty) {
                        Text("your_username")
                            .font(.plusJakartaSans(size: 17))
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(Color.digitGrayLight)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            if viewModel.isCheckingUserName {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Checking username...")
                        .font(.plusJakartaSans(size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            if let error = viewModel.errorMessage, !error.isEmpty {
                Text(error)
                    .font(.plusJakartaSans(size: 14))
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            } else if !viewModel.isUserNameValid && !viewModel.userName.isEmpty {
                Text("Usernames must be at least 3 characters, only letters, numbers, and underscores.")
                    .font(.plusJakartaSans(size: 14))
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
    }
    
    private var emailStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("We'll use your email only to notify you about important changes to the app, such as policy updates. We will never use it for marketing or spam.")
                .font(.plusJakartaSans(size: 16))
                .foregroundStyle(Color.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.plusJakartaSans(size: 14))
                    .foregroundStyle(.secondary)
                HStack {
                    Text(viewModel.email)
                        .font(.plusJakartaSans(size: 17))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: viewModel.isEmailVerified ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(viewModel.isEmailVerified ? Color.green : Color.red)
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color.digitGrayLight)
                .cornerRadius(10)
                Text(viewModel.isEmailVerified ? "Email verified" : "Email not verified")
                    .font(.plusJakartaSans(size: 14))
                    .foregroundStyle(viewModel.isEmailVerified ? .green : .red)
                HStack(spacing: 16) {
                    Button(action: {
                        Task {
                            isCheckingVerification = true
                            await viewModel.refreshEmailVerificationStatus()
                            isCheckingVerification = false
                        }
                    }) {
                        if isCheckingVerification {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Verify")
                                .font(.plusJakartaSans(size: 14, weight: .medium))
                                .foregroundStyle(Color.digitBrand)
                        }
                    }
                    .disabled(isCheckingVerification)
                    Button(action: {
                        Task { await viewModel.resendVerificationEmail() }
                    }) {
                        Text("Resend verification email")
                            .font(.plusJakartaSans(size: 14, weight: .medium))
                            .foregroundStyle(Color.digitAccentRed)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var dateOfBirthStep: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("You must be at least 18 years old to use Digit.")
                .font(.plusJakartaSans(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            DatePicker(
                "",
                selection: $viewModel.dateOfBirth,
                in: viewModel.dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .padding(.horizontal, 16)
            .frame(height: 180)
            .background(Color.digitGrayLight)
            .cornerRadius(10)
        }
    }
    
    private var genderStep: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select your pronouns")
                .font(.plusJakartaSans(size: 16))
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
                            .font(.plusJakartaSans(size: 17))
                        Spacer()
                        if viewModel.selectedGender == gender {
                            Image(systemName: "checkmark")
                                .font(.plusJakartaSans(size: 17, weight: .medium))
                                .foregroundStyle(Color.digitBrand)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(Color.digitGrayLight)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
    
    private var regionStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("This is only used to ensure units of measurement match your region. You can change this later in settings.")
                .font(.plusJakartaSans(size: 16))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            VStack(spacing: 16) {
                ForEach(["us", "europe", "asia"], id: \ .self) { region in
                    Button(action: {
                        withAnimation { viewModel.selectedRegion = region }
                    }) {
                        HStack {
                            Text(region.capitalized)
                                .font(.plusJakartaSans(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.selectedRegion == region {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.digitBrand)
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(Color.digitGrayLight)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var enableNotificationStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Stay on track by enabling reminders and notifications.")
                .font(.plusJakartaSans(size: 16))
                .foregroundStyle(Color.secondary)
                .padding(.horizontal)
            Toggle(isOn: $viewModel.notificationsEnabled) {
                Text("Enable notifications")
                    .font(.plusJakartaSans(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.digitAccentRed))
            .padding(.horizontal)
        }
    }
}

#if DEBUG
#Preview {
    OnboardingView(viewModel: OnboardingViewModel(onComplete: {}, onDismiss: {}))
}
#endif 