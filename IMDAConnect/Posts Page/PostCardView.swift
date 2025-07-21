//
//  PostCardView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/6/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

struct PostCardView: View {
    let post: Post

    @State private var isLiked = false
    @State private var likeCount: Int
    private let db = Firestore.firestore()

    init(post: Post) {
        self.post = post
        _likeCount = State(initialValue: post.likeCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            authorInfo
            postImage
            caption
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            actionButtons
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
        .onAppear {
            checkIfLiked()
        }
    }

    private var authorImage: some View {
        if let url = URL(string: post.authorProfileURL), !post.authorProfileURL.isEmpty {
            return AnyView(
                WebImage(url: url)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.purple.opacity(0.15), radius: 4, x: 0, y: 2)
            )
        } else {
            return AnyView(
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .overlay(
                        Text(authorInitials)
                            .font(.headline)
                            .foregroundColor(Color.purple)
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.purple.opacity(0.15), radius: 4, x: 0, y: 2)
            )
        }
    }

    private var authorInfo: some View {
        HStack {
            authorImage
            VStack(alignment: .leading, spacing: 2) {
                Text(post.authorUsername)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(timeAgo(since: post.timestamp.dateValue()))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
        }
    }

    private var postImage: some View {
        WebImage(url: URL(string: post.imageURL))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(14)
            .shadow(radius: 4)
            .onTapGesture(count: 2) {
                toggleLike()
            }
    }

    private var caption: some View {
        Text(post.caption)
            .foregroundStyle(.white.opacity(0.92))
            .font(.body)
            .padding(.vertical, 2)
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button(action: toggleLike) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? .red : .white.opacity(0.8))
                    .scaleEffect(isLiked ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isLiked)
            }

            Text("\(likeCount)")
                .foregroundStyle(.white.opacity(0.7))
                .font(.caption)

            Spacer()
        }
    }

    private var authorInitials: String {
        nameInitials(from: post.authorUsername)
    }

    private func nameInitials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined()
    }

    private func timeAgo(since date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }


    private func toggleLike() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postRef = db.collection("posts").document(post.postId)

        db.runTransaction({ transaction, errorPointer -> Any? in
            do {
                let postDoc = try transaction.getDocument(postRef)
                let currentLikes = postDoc.data()?["likeCount"] as? Int ?? 0

                if isLiked {
                    transaction.updateData([
                        "likeCount": currentLikes - 1,
                        "likedBy": FieldValue.arrayRemove([userUID])
                    ], forDocument: postRef)
                } else {
                    transaction.updateData([
                        "likeCount": currentLikes + 1,
                        "likedBy": FieldValue.arrayUnion([userUID])
                    ], forDocument: postRef)
                }
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            return nil
        }) { _, error in
            if error == nil {
                isLiked.toggle()
                likeCount += isLiked ? 1 : -1
            } else {
                print("❌ Error toggling like: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    private func checkIfLiked() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let postRef = db.collection("posts").document(post.postId)

        postRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let likedBy = data["likedBy"] as? [String] {
                isLiked = likedBy.contains(userUID)
            }
        }
    }
}

