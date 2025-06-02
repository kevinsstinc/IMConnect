//
//  LoginView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 31/5/25.
//

import SwiftUI
import Combine
import FirebaseAnalytics

struct LoginView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss
    
    @AppStorage("isUserLoggedIn") var isUserLoggedIn = false
    @State private var isAnimating = false
    @State private var isLoading = false
  @FocusState private var focus: FocusableField?

  private func signInWithGoogle() {
    Task {
      if await viewModel.signInWithGoogle() == true {
        dismiss()
      }
        
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

                  VStack(spacing: 40) {
                      Spacer().frame(height: 50)

                      Image(systemName: "person.circle.fill")
                          .resizable()
                          .scaledToFit()
                          .frame(width: 150, height: 150)
                          .foregroundStyle(.white)
                          .shadow(radius: 15)
                          .scaleEffect(isAnimating ? 1.1 : 0.95)
                          .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

                      Text("Welcome to IMDAConnect")
                          .multilineTextAlignment(.center)
                          .font(.largeTitle.bold())
                          .foregroundStyle(.white)
                          .transition(.opacity)

                      Text("Sign in with your Google account/email to continue")
                          .font(.title3)
                          .foregroundStyle(.white.opacity(0.85))
                          .padding(.horizontal, 30)
                          .multilineTextAlignment(.center)
                      if isLoading {
                          ProgressView()
                              .progressViewStyle(CircularProgressViewStyle(tint: .white))
                              .scaleEffect(1.5)
                      } else {
                          NavigationLink{
                              SignUpView()
                                  .environmentObject(viewModel)
                          }label: {
                             
                                  HStack {
                                      Image(systemName: "envelope")
                                          .resizable()
                                          .frame(width: 34, height: 24)
                                          .foregroundStyle(.black)
                                          .padding(.trailing, 20)
                                      
                                      Text("Sign in with Email")
                                          .fontWeight(.semibold)
                                          .foregroundStyle(.black)
                                  }
                                  .frame(width: 250, height: 50)
                                  .background(Color.white)
                                  .cornerRadius(12)
                                  .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                              
                              
                          }
                          .buttonStyle(ScaleButtonStyle())
                          
                      }
                      
                      if isLoading {
                          ProgressView()
                              .progressViewStyle(CircularProgressViewStyle(tint: .white))
                              .scaleEffect(1.5)
                      } else {
                          Button(action: signInWithGoogle) {
                              HStack {
                                  Image("google_icon")
                                      .resizable()
                                      .frame(width: 24, height: 24)

                                  Text("Sign in with Google")
                                      .fontWeight(.semibold)
                                      .foregroundColor(.black)
                              }
                              .frame(width: 250, height: 50)
                              .background(Color.white)
                              .cornerRadius(12)
                              .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                          }
                          .buttonStyle(ScaleButtonStyle())
                      }

                      Spacer()
                  }
                  
              }
              .onAppear {
                  isAnimating = true
              }
          }
  }



#Preview {
      LoginView()
    .environmentObject(AuthenticationViewModel())
}


