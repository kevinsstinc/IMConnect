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

  private func signInWithEmailPassword() {
    Task {
      if await viewModel.signInWithEmailPassword() == true {
        dismiss()
      }
    }
  }

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
                          .foregroundColor(.white)
                          .shadow(radius: 15)
                          .scaleEffect(isAnimating ? 1.1 : 0.95)
                          .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)

                      Text("Welcome to IMDAConnect")
                          .multilineTextAlignment(.center)
                          .font(.largeTitle.bold())
                          .foregroundColor(.white)
                          .transition(.opacity)

                      Text("Sign in with your Google account/email to continue")
                          .font(.title3)
                          .foregroundColor(.white.opacity(0.85))
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
                                          .foregroundColor(.black)
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

//VStack {
//  Image("Login")
//    .resizable()
//    .aspectRatio(contentMode: .fit)
//    .frame(minHeight: 300, maxHeight: 400)
//  Text("Login")
//    .font(.largeTitle)
//    .fontWeight(.bold)
//    .frame(maxWidth: .infinity, alignment: .leading)
//
//  HStack {
//    Image(systemName: "at")
//    TextField("Email", text: $viewModel.email)
//      .textInputAutocapitalization(.never)
//      .disableAutocorrection(true)
//      .focused($focus, equals: .email)
//      .submitLabel(.next)
//      .onSubmit {
//        self.focus = .password
//      }
//  }
//  .padding(.vertical, 6)
//  .background(Divider(), alignment: .bottom)
//  .padding(.bottom, 4)
//
//  HStack {
//    Image(systemName: "lock")
//    SecureField("Password", text: $viewModel.password)
//      .focused($focus, equals: .password)
//      .submitLabel(.go)
//      .onSubmit {
//        signInWithEmailPassword()
//      }
//  }
//  .padding(.vertical, 6)
//  .background(Divider(), alignment: .bottom)
//  .padding(.bottom, 8)
//
//  if !viewModel.errorMessage.isEmpty {
//    VStack {
//      Text(viewModel.errorMessage)
//        .foregroundColor(Color(UIColor.systemRed))
//    }
//  }
//
//  Button(action: signInWithEmailPassword) {
//    if viewModel.authenticationState != .authenticating {
//      Text("Login")
//        .padding(.vertical, 8)
//        .frame(maxWidth: .infinity)
//    }
//    else {
//      ProgressView()
//        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//        .padding(.vertical, 8)
//        .frame(maxWidth: .infinity)
//    }
//  }
//  .disabled(!viewModel.isValid)
//  .frame(maxWidth: .infinity)
//  .buttonStyle(.borderedProminent)
//
//  HStack {
//    VStack { Divider() }
//    Text("or")
//    VStack { Divider() }
//  }
//
//  Button(action: signInWithGoogle) {
//    Text("Sign in with Google")
//      .padding(.vertical, 8)
//      .frame(maxWidth: .infinity)
//      .background(alignment: .leading) {
//        Image("Google")
//          .frame(width: 30, alignment: .center)
//      }
//  }
//  .foregroundColor(colorScheme == .dark ? .white : .black)
//  .buttonStyle(.bordered)
//
//  HStack {
//    Text("Don't have an account yet?")
//    Button(action: { viewModel.switchFlow() }) {
//      Text("Sign up")
//        .fontWeight(.semibold)
//        .foregroundColor(.blue)
//    }
//  }
//  .padding([.top, .bottom], 50)
//
//}
//.listStyle(.plain)
//.padding()
//.analyticsScreen(name: "\(Self.self)")
