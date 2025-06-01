//
//  AuthView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/5/25.
//


import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var school = ""
    @State private var isSignUp = false

    var body: some View {
        VStack(spacing: 20) {
            Text(isSignUp ? "Create Account" : "Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .transition(.scale.combined(with: .opacity))

            Group {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                if isSignUp {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    TextField("School", text: $school)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))

            Button(action: {
                if isSignUp {
                    AuthManager.shared.signUp(email: email, password: password, name: name, school: school)
                } else {
                    AuthManager.shared.signIn(email: email, password: password)
                }
            }) {
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)

            Button(action: {
                withAnimation {
                    isSignUp.toggle()
                }
            }) {
                Text(isSignUp ? "Already have an account? Sign In" : "New here? Create an account")
                    .font(.caption)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 15)
        .padding()
    }
}