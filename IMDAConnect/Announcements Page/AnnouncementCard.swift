//
//  AnnouncementCard.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 13/6/25.
//
import SwiftUI

struct AnnouncementCard: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(announcement.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Spacer()
                Text(announcement.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Text(announcement.content)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
            HStack {
                ForEach(announcement.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white.opacity(0.9))
                        .cornerRadius(8)
                }
                Spacer()
                Text("By \(announcement.author)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
}
