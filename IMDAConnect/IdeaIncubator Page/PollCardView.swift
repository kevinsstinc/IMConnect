//
//  PollCardView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 7/7/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PollCardView: View {
    let poll: Poll
    var onVote: (Int) -> Void

    private var totalVotes: Int {
        poll.votes.values.reduce(0, +)
    }

    private var userVotedIndex: Int? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return poll.votedBy[uid]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(initials(from: poll.authorName))
                            .font(.headline)
                            .foregroundStyle(.purple)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(poll.authorName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(timeAgo(since: poll.timestamp.dateValue()))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
            }

            Text(poll.question)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)

            ForEach(poll.options.indices, id: \.self) { idx in
                PollOptionBar(
                    text: poll.options[idx],
                    count: poll.votes[String(idx)] ?? 0,
                    total: totalVotes,
                    isSelected: userVotedIndex == idx,
                    canVote: true,
                    onTap: {
                        onVote(idx)
                    }
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private func initials(from name: String) -> String {
        let comps = name.split(separator: " ")
        let initials = comps.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined()
    }

    private func timeAgo(since date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
