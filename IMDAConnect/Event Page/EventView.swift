//
//  EventView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 12/6/25.
//

import SwiftUI

struct EventView: View {
    @State private var pulse = false
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 74/255, green: 31/255, blue: 91/255),
                    Color(red: 100/255, green: 42/255, blue: 122/255)
                ]),
                startPoint: pulse ? .topLeading : .bottomTrailing,
                endPoint: pulse ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: pulse)
            .ignoresSafeArea()
        }
        ScrollView{
            VStack{
                HStack{
                    Text("Events")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .padding(.leading, 20)
                    Spacer()
                }
                    
            }
        }
    }
}

#Preview {
    EventView()
}
