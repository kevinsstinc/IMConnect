//
//  PastProject.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/5/25.
//

import SwiftUI

struct PastProject: View {
    var title: String
    var date: String
    var about: String
    var image: String

    @State private var detailSheet: Bool = false
    @State private var pulse = false

    var body: some View {
        VStack {
            Button {
                detailSheet = true
            } label: {
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 150, height: 100)
                        .padding(.leading, 20)
                    Text(title)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    Text(date)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                }
            }
        }
        .sheet(isPresented: $detailSheet) {
            NavigationView {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 74/255, green: 31/255, blue: 91/255),
                            Color(red: 100/255, green: 42/255, blue: 122/255)
                        ]),
                        startPoint: pulse ? .topLeading : .bottomTrailing,
                        endPoint: pulse ? .bottomTrailing : .topLeading
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: pulse)

                    ZStack {
                        ForEach(0..<15, id: \.self) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: CGFloat.random(in: 3...12))
                                .position(
                                    x: CGFloat.random(in: 0...400),
                                    y: CGFloat.random(in: 0...800)
                                )
                                .scaleEffect(pulse ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: Double.random(in: 4...8))
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...3)),
                                    value: pulse
                                )
                        }
                    }

                    ScrollView {
                        VStack(spacing: 30) {
                            VStack(spacing: 20) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 360, height: 160)
                                        .shadow(color: Color(red: 74/255, green: 31/255, blue: 91/255).opacity(0.6), radius: 20, x: 0, y: 10)
                                        .shadow(color: Color(red: 100/255, green: 42/255, blue: 122/255).opacity(0.4), radius: 15, x: 5, y: 5)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )

                                    Image(systemName: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundStyle(.white)
                                        .scaleEffect(pulse ? 1.15 : 0.85)
                                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulse)
                                        .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 2)
                                }

                                Text(title)
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                    .scaleEffect(pulse ? 1.05 : 0.95)
                                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: pulse)
                            }
                            .padding(.top, 20)

                            VStack(spacing: 20) {
                                InfoCard(
                                    icon: "calendar.badge.clock",
                                    title: "Date",
                                    content: date,
                                    accentColor: Color(red: 150/255, green: 100/255, blue: 180/255)
                                )

                                InfoCard(
                                    icon: "doc.text.fill",
                                    title: "About",
                                    content: about.isEmpty ? "No additional details provided." : about,
                                    accentColor: Color(red: 120/255, green: 80/255, blue: 150/255),
                                    isExpandable: true
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            detailSheet = false
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                        pulse.toggle()
                    }
                }
            }
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let content: String
    let accentColor: Color
    var isExpandable: Bool = false
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(accentColor)
                    .font(.title2)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                if isExpandable && content.count > 100 {
                    Button {
                        withAnimation(.spring()) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.caption)
                    }
                }
            }
            
            Text(content)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(isExpandable && !isExpanded ? 3 : nil)
                .animation(.easeInOut, value: isExpanded)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.12))
                .shadow(color: Color(red: 74/255, green: 31/255, blue: 91/255).opacity(0.4), radius: 12, x: 0, y: 6)
                .shadow(color: Color(red: 100/255, green: 42/255, blue: 122/255).opacity(0.3), radius: 8, x: 3, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), accentColor.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(isExpanded ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.5), value: isExpanded)
    }
}

#Preview {
    PastProject(title: "", date: "", about: "", image: "")
}
