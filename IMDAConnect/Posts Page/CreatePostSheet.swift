//
//  CreatePostSheet.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 24/6/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreatePostSheet: View {
    @ObservedObject var manager: PostsManager
    @Binding var isPresented: Bool
    @AppStorage("name") var name: String = "Your Name"
    @State private var content: String = ""
    @State private var pulse = false
    
    var body: some View {
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
            
            VStack(spacing: 20) {
                Text("New Post")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                CreateInputCard(title: "What's on your mind?", text: $content, placeholder: "Write your post...", multiline: true)
                Button(action: {
                    if let uid = Auth.auth().currentUser?.uid, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        manager.addPost(content: content, authorName: name, authorUID: uid)
                        isPresented = false
                    }
                }) {
                    Text("Post")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.25))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding()
        }
        .onAppear { pulse = true }
    }
}
