//
//  PostCard.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 24/6/25.
//
import SwiftUI
import FirebaseFirestore

struct PostCard: View {
    let post: Post
    
    var initials: String {
        let comps = post.authorName.split(separator: " ")
        let initials = comps.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined()
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(initials)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.purple.opacity(0.8))
                )
                .shadow(color: .purple.opacity(0.15), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(post.authorName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(post.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                Text(post.content)
                    .foregroundColor(.white.opacity(0.92))
                    .font(.body)
                    .padding(.vertical, 2)
                HStack(spacing: 8) {
                    Image(systemName: "hand.thumbsup.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                    Text("\(post.likes ?? 0)")
                        .foregroundColor(.white.opacity(0.7))
                    .font(.caption)
                }
                
                
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.18), Color.purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
}

