//
//  ContentView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 29/5/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isUserLoggedIn") var isUserLoggedIn = false
    var body: some View {
        if isUserLoggedIn == true{
            TabBarContainer()
        }else{
            LoginView()
        }
            
    }
}

#Preview {
    ContentView()
}


