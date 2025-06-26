//
//  PostDetailView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 24/6/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PostDetailView: View {
    let post: Post
    @AppStorage("name") var name: String = "Your Name"
    @StateObject private var commentsManager: CommentsManager
    @State private var commentText = ""
    @State private var isSharing = false
    @State private var isLiked = false
    @State private var likeCount: Int = 0
    @State private var likedBy: [String] = []
    let db = Firestore.firestore()
    let userId = Auth.auth().currentUser?.uid ?? ""
    
    init(post: Post) {
        self.post = post
        _commentsManager = StateObject(wrappedValue: CommentsManager(postId: post.id ?? ""))
        _likeCount = State(initialValue: post.likes ?? 0)
        _likedBy = State(initialValue: post.likedBy ?? [])
        _isLiked = State(initialValue: (post.likedBy ?? []).contains(Auth.auth().currentUser?.uid ?? ""))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 74/255, green: 31/255, blue: 91/255),
                    Color(red: 100/255, green: 42/255, blue: 122/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    PostCard(post: Post(
                        id: post.id,
                        authorName: post.authorName,
                        authorUID: post.authorUID,
                        content: post.content,
                        date: post.date,
                        likes: likeCount,
                        likedBy: likedBy
                    ))
                    
                    HStack(spacing: 24) {
                        Button(action: {
                            toggleLike()
                        }) {
                            Label(isLiked ? "Liked" : "Like", systemImage: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        
                        Button(action: {
                            isSharing = true
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                        .sheet(isPresented: $isSharing) {
                            ActivityView(activityItems: [post.content])
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 2)
                    
                    Text("Comments")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 2)
                        .padding(.top, 8)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(commentsManager.comments) { comment in
                                HStack(alignment: .top, spacing: 10) {
                                    Circle()
                                        .fill(Color.white.opacity(0.85))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Text(comment.authorName.split(separator: " ").compactMap { $0.first }.prefix(2).map { String($0) }.joined())
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(Color.purple.opacity(0.8))
                                        )
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(comment.authorName)
                                                .font(.subheadline.bold())
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text(comment.date, style: .time)
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                        Text(comment.content)
                                            .foregroundColor(.white.opacity(0.92))
                                            .font(.body)
                                    }
                                }
                                .padding(8)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .padding(10)
                        .background(Color.white.opacity(0.08).cornerRadius(8))
                        .foregroundColor(.white)
                    Button {
                        if let uid = Auth.auth().currentUser?.uid,
                           !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            commentsManager.addComment(content: commentText, authorName: name, authorUID: uid)
                            commentText = ""
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 2)
            }
            .padding()
            .padding(.bottom, 55)
            .onAppear {
                fetchLikeStatus()
            }
        }
    }
    
    private func fetchLikeStatus() {
        guard let postId = post.id else { return }
        db.collection("posts").document(postId).addSnapshotListener { doc, _ in
            guard let data = doc?.data() else { return }
            let likes = data["likes"] as? Int ?? 0
            let likedByArr = data["likedBy"] as? [String] ?? []
            likeCount = likes
            likedBy = likedByArr
            isLiked = likedByArr.contains(userId)
        }
    }
    
    private func toggleLike() {
        guard let postId = post.id, !userId.isEmpty else { return }
        let ref = db.collection("posts").document(postId)
        if isLiked {
            ref.updateData([
                "likes": FieldValue.increment(Int64(-1)),
                "likedBy": FieldValue.arrayRemove([userId])
            ])
        } else {
            ref.updateData([
                "likes": FieldValue.increment(Int64(1)),
                "likedBy": FieldValue.arrayUnion([userId])
            ])
        }
    }
}
