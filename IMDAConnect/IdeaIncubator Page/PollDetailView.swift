//
//  PollDetailView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 7/7/25.
//

import SwiftUI

struct PollDetailView: View {
    let poll: Poll
    @Environment(\.dismiss) var dismiss
    @State private var pulse = false

    var body: some View {
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
                    ForEach(0..<10, id: \.self) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: CGFloat.random(in: 5...12))
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

                                Image(systemName: "lightbulb.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(.white)
                            }

                            Text(poll.question)
                                .font(.largeTitle.bold())
                                .padding(.leading,10)
                                .padding(.trailing,10)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                
                        }
                        .padding(.top, 20)

                        VStack(spacing: 20) {
                            InfoCard(
                                icon: "person.crop.circle",
                                title: "Author",
                                content: poll.authorName,
                                accentColor: Color.white
                            )

                            InfoCard(
                                icon: "doc.text.fill",
                                title: "Description",
                                content: poll.description.isEmpty ? "No description provided." : poll.description,
                                accentColor: Color.white,
                                isExpandable: true
                            )

                            InfoCard(
                                icon: "chart.bar.fill",
                                title: "Options & Votes",
                                content: poll.options.enumerated().map {
                                    "\($0.element): \(poll.votes[String($0.offset)] ?? 0) votes"
                                }.joined(separator: "\n"),
                                accentColor: Color.white
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
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
