//
//  PostsView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 17/6/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var authorName: String
    var authorUID: String
    var content: String
    var date: Date
    var likes: Int?
    var likedBy: [String]?
}

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var postId: String
    var authorName: String
    var authorUID: String
    var content: String
    var date: Date
}

struct PostsView: View {
    @StateObject private var manager = PostsManager()
    @State private var showCreateSheet = false
    @State private var pulse = false
    
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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack {
                            Text("Posts")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                            Button(action: { showCreateSheet = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                            .sheet(isPresented: $showCreateSheet) {
                                CreatePostSheet(manager: manager, isPresented: $showCreateSheet)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                        
                        VStack(spacing: 14) {
                            ForEach(manager.posts) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    PostCard(post: post)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 36)
                    }
                }
                .onAppear { pulse = true }
            }
        }
    }
}


#Preview{
    PostsView()
}
