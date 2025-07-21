//
//  PollOptionBar.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 7/7/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PollOptionBar: View {
    let text: String
    let count: Int
    let total: Int
    let isSelected: Bool
    let canVote: Bool
    var onTap: () -> Void

    @State private var animateTap = false
    @State private var animatedPercent: Double = 0

    var percent: Double {
        total == 0 ? 0 : Double(count) / Double(total)
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                animateTap = true
            }
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    animateTap = false
                }
            }
        }) {
            HStack {
                Text(text)
                    .foregroundStyle(.white)
                    .fontWeight(isSelected ? .bold : .regular)
                    .scaleEffect(animateTap ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: animateTap)

                Spacer()

                Text("\(count)")
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.caption)
                    .opacity(animateTap ? 0.8 : 1.0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))

                    if animatedPercent > 0 {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.purple.opacity(0.5) : Color.purple.opacity(0.25))
                            .frame(
                                width: animatedPercent >= 1.0
                                ? UIScreen.main.bounds.width * 0.8
                                : CGFloat(animatedPercent) * UIScreen.main.bounds.width * 0.6
                            )
                            .animation(.easeInOut(duration: 0.4), value: animatedPercent)
                    }
                }
            )
            .scaleEffect(animateTap ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: animateTap)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animatedPercent = percent
            }
        }
        .onChange(of: percent) {
            withAnimation(.easeOut(duration: 0.4)) {
                animatedPercent = percent
            }
        }
    }
}

