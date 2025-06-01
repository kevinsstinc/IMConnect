//
//  AuthenticationView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 31/5/25.
//


import SwiftUI
import Combine

struct AuthenticationView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel

  var body: some View {
    VStack {
      switch viewModel.flow {
      case .login:
        LoginView()
          .environmentObject(viewModel)
      case .signUp:
        SignUpView()
          .environmentObject(viewModel)
      }
    }
  }
}


#Preview{
    AuthenticationView()
      .environmentObject(AuthenticationViewModel())
}
