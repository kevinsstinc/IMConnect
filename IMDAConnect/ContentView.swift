//
//  ContentView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 29/5/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isUserLoggedIn") var isUserLoggedIn = false
    @State private var selectedTab: Tab = .profile
    var body: some View {
        if isUserLoggedIn == true{
            CustomTabBar(selectedTab: $selectedTab)
        }else{
            LoginView()
        }
            
    }
}

#Preview {
    ContentView()
}


