//
//  NoConnectionView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 10/7/25.
//
import SwiftUI

struct NoConnectionView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.white.opacity(0.8))
                Text("No Internet Connection")
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text("You seem to be offline! IMConnect requires a network connection to function properly. Please check your internet settings and try again.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding()
        }
    }
}
