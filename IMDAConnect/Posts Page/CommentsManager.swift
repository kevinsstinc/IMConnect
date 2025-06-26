//
//  CommentsManager.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 24/6/25.
//

import SwiftUI
import FirebaseFirestore

class CommentsManager: ObservableObject {
    @Published var comments: [Comment] = []
    let db = Firestore.firestore()
    let postId: String
    
    init(postId: String) {
        self.postId = postId
        fetchComments()
    }
    
    func fetchComments() {
        db.collection("posts").document(postId).collection("comments")
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.comments = docs.compactMap { try? $0.data(as: Comment.self) }
            }
    }
    func addComment(content: String, authorName: String, authorUID: String) {
        let newComment = Comment(postId: postId, authorName: authorName, authorUID: authorUID, content: content, date: Date())
        do {
            _ = try db.collection("posts").document(postId).collection("comments").addDocument(from: newComment)
        } catch {
            print("Error adding comment: \(error)")
        }
    }
}
