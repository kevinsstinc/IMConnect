//
//  PostView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/6/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SDWebImageSwiftUI


struct PostsView: View {
    @State private var pulse = false
    @State private var showCreateSheet = false
    @State private var posts = [Post]()
    @State private var isRefreshing = false
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 74/255, green: 31/255, blue: 91/255),
                        Color(red: 100/255, green: 42/255, blue: 122/255)
                    ]),
                    startPoint: pulse ? .topLeading : .bottomTrailing,
                    endPoint: pulse ? .bottomTrailing : .topLeading
                )
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: pulse)
                .ignoresSafeArea()
                .onAppear {
                    pulse = true
                    fetchPosts()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack {
                            Text("Posts")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                showCreateSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 28)
                        
                        VStack(spacing: 18) {
                            ForEach(posts) { post in
                                NavigationLink(destination: SinglePostView(post: post)) {
                                    PostCardView(post: post)
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 36)
                    }
                    .refreshable {
                        await reloadPosts()
                    }
                    .padding(.bottom, 100)
                }
                
            }
            .sheet(isPresented: $showCreateSheet) {
                CreatePostView {
                    showCreateSheet = false
                    fetchPosts()
                }
            }

        }
        
    }
        
    func fetchPosts() {
        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let snapshot = snapshot {
                    posts = snapshot.documents.map { Post(from: $0.data(), id: $0.documentID) }
                } else if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                }
            }
    }
    
    func reloadPosts() async {
        await withCheckedContinuation { continuation in
            db.collection("posts")
                .order(by: "timestamp", descending: true)
                .getDocuments { snapshot, error in
                    if let snapshot = snapshot {
                        posts = snapshot.documents.map { Post(from: $0.data(), id: $0.documentID) }
                    } else if let error = error {
                        print("Error refreshing posts: \(error.localizedDescription)")
                    }
                    continuation.resume()
                }
        }
    }
}



#Preview{
    PostsView()
}
