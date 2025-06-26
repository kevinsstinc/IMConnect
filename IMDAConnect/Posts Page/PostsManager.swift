//
//  PostsManager.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 24/6/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class PostsManager: ObservableObject {
    @Published var posts: [Post] = []
    let db = Firestore.firestore()
    
    init() { fetchPosts() }
    
    func fetchPosts() {
        db.collection("posts")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.posts = docs.compactMap { try? $0.data(as: Post.self) }
            }
    }
    
    func addPost(content: String, authorName: String, authorUID: String) {
        let newPost = Post(authorName: authorName, authorUID: authorUID, content: content, date: Date(), likes: 0, likedBy: [])
        do {
            _ = try db.collection("posts").addDocument(from: newPost)
        } catch {
            print("Error adding post: \(error)")
        }
    }
}
