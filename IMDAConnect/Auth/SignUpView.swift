//
//  SignUpView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 31/5/25.
//

import SwiftUI
import Combine
import FirebaseAnalytics

enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
}

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: FocusableField?
    @AppStorage("isUserLoggedIn") var isUserLoggedIn = false
    @State private var isAnimating = false
    @State private var isLoading = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
    
    private func signUpWithEmailPassword() {
        Task {
            isLoading = true
            if await viewModel.signUpWithEmailPassword(email: email, password: password) == true {
                dismiss()
                isUserLoggedIn = true
            } else {
                errorMessage = "Error occurred. Please try again"
            }
            isLoading = false
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0, blue: 0.3),
                    Color(red: 0.4, green: 0.1, blue: 0.5)
                ]),
                startPoint: isAnimating ? .topLeading : .bottomTrailing,
                endPoint: isAnimating ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: isAnimating)
            .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 18) {
                    Text("Create an Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CustomTextField(
                        icon: "at",
                        placeholder: "Email",
                        text: $email,
                        isSecure: false,
                        focusField: .email,
                        focus: $focus
                    )
                    .onSubmit { focus = .password }
                    
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Password",
                        text: $password,
                        isSecure: true,
                        focusField: .password,
                        focus: $focus
                    )
                    .onSubmit { focus = .confirmPassword }
                    
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Confirm Password",
                        text: $confirmPassword,
                        isSecure: true,
                        focusField: .confirmPassword,
                        focus: $focus
                    )
                    .onSubmit { signUpWithEmailPassword() }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: signUpWithEmailPassword) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(isValid ? Color.white.opacity(0.15) : Color.gray.opacity(0.3))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .contentShape(Rectangle())
                    }
                    .disabled(!isValid)
                    
                }
                .padding()
                .background(.ultraThinMaterial.opacity(0.3))
                .cornerRadius(20)
                .shadow(color: .white.opacity(0.1), radius: 10, x: 0, y: 6)
                .padding()
                HStack{
                    Text("Already have an account? ")
                        .foregroundStyle(.white)
                    NavigationLink(destination: SignInView().environmentObject(AuthenticationViewModel())) {
                            Text("Log in")
                                .foregroundStyle(.blue)
                                .fontWeight(.semibold)
                        }
                }
            }
            .frame(maxHeight: .infinity)
            .padding()
        }
        .onAppear { isAnimating = true }
        
    }
    
}

struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var focusField: FocusableField
    var focus: FocusState<FocusableField?>.Binding
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.white)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused(focus, equals: focusField)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .focused(focus, equals: focusField)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
        .foregroundStyle(.white)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthenticationViewModel())
}


