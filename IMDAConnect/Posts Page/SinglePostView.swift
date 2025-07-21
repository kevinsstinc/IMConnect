//
//  SinglePostView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/6/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

struct SinglePostView: View {
    let post: Post
    @State private var selectedUserUID: String? = nil
    @State private var showProfile = false
    @State private var isLiked = false
    @State private var likeCount = 0
    @State private var comments: [Comment] = []
    @State private var commentText = ""
    @State private var showToxicityAlert = false

    private let db = Firestore.firestore()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 74/255, green: 31/255, blue: 91/255),
                    Color(red: 100/255, green: 42/255, blue: 122/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    userInfoSection
                    postImageSection
                    actionButtonsSection
                    captionSection
                    commentsSection
                    addCommentSection
                }
                .padding()
                .padding(.bottom, 100)
            }
            
        }
        .onAppear {
            listenToLikeCount()
            fetchComments()
        }
        .alert("Inappropriate Content", isPresented: $showToxicityAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your comment appears to contain inappropriate content and was not posted.")
        }
    }

    var userInfoSection: some View {
        HStack {
            Button {
                self.selectedUserUID = post.authorUID
                self.showProfile = true
            } label: {
                HStack(spacing: 12) {
                    if let url = URL(string: post.authorProfileURL), !post.authorProfileURL.isEmpty {
                        WebImage(url: url)
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 44, height: 44)
                    } else {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text(authorInitials)
                                    .font(.headline)
                                    .foregroundColor(Color.purple)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorUsername)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(post.timestamp.dateValue().timeAgo())
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle()) 
            Spacer()
            NavigationLink(
                destination: selectedUserUID != nil
                    ? AnyView(AuthorProfilePage(userUID: selectedUserUID!))
                    : AnyView(EmptyView()),
                isActive: $showProfile
            ) {
                EmptyView()
            }


        }
    }


    var postImageSection: some View {
        WebImage(url: URL(string: post.imageURL))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(14)
            .onTapGesture(count: 2) { likePost() }
    }

    var actionButtonsSection: some View {
        HStack(spacing: 16) {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundStyle(isLiked ? .red : .white.opacity(0.7))
                .onTapGesture { likePost() }
            Image(systemName: "bubble.right")
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text("\(likeCount) likes")
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.8))
        }
        .font(.system(size: 20))
    }

    var captionSection: some View {
        Text(post.caption)
            .foregroundStyle(.white.opacity(0.92))
            .font(.body)
            .padding(.vertical, 2)
    }

    var commentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comments")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))

            ForEach(comments) { comment in
                commentRow(comment)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    var addCommentSection: some View {
        HStack {
            CommentInputCard(text: $commentText, placeholder: "Add a comment...", multiline: false)
                .frame(height: 50)

            Button(action: addComment) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Color.purple.opacity(0.7))
                    .clipShape(Circle())
            }
            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.top, 4)
    }

    func commentRow(_ comment: Comment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            if let url = URL(string: comment.authorProfileURL), !comment.authorProfileURL.isEmpty {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(nameInitials(from: comment.authorName))
                            .font(.headline)
                            .foregroundStyle(Color.purple)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(comment.authorName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text(comment.timestamp.dateValue().timeAgo())
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Text(comment.content)
                    .foregroundStyle(.white.opacity(0.9))
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.07))
        .cornerRadius(12)
    }

    func likePost() {
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
            }
        }
    }

    func fetchComments() {
        db.collection("posts").document(post.postId).collection("comments")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                comments = docs.map { Comment(from: $0.data(), id: $0.documentID) }
            }
    }

    func addComment() {
        guard let user = Auth.auth().currentUser,
              !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        moderateComment(content: commentText) { isSafe in
            if isSafe {
                let userDoc = db.collection("users").document(user.uid)
                userDoc.getDocument { doc, _ in
                    let data = doc?.data()
                    let name = data?["name"] as? String ?? (user.displayName ?? "Anonymous")
                    let profileURL = data?["profileURL"] as? String ?? (user.photoURL?.absoluteString ?? "")

                    let commentData: [String: Any] = [
                        "authorUID": user.uid,
                        "authorName": name,
                        "authorProfileURL": profileURL,
                        "content": commentText,
                        "timestamp": Timestamp()
                    ]

                    db.collection("posts").document(post.postId).collection("comments").addDocument(data: commentData)
                    commentText = ""
                }
            } else {
                showBadCommentAlert()
            }
        }
    }

    func moderateComment(content: String, completion: @escaping (Bool) -> Void) {
        guard !content.isEmpty else {
            print("⚠️ Empty comment, skipping moderation")
            completion(true)
            return
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "commentanalyzer.googleapis.com"
        components.path = "/v1alpha1/comments:analyze"
        components.queryItems = [
            URLQueryItem(name: "key", value: "API_KEY_HERE")
        ]
        
        guard let url = components.url else {
            print("❌ Invalid Perspective API URL")
            completion(true)
            return
        }
        
        let requestDict: [String: Any] = [
            "comment": ["text": content],
            "languages": ["en"],
            "requestedAttributes": ["TOXICITY": [:]]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestDict) else {
            print("❌ Failed to serialize JSON")
            completion(true)
            return
        }
        
        print("Sending moderation API request...")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Perspective API error: \(error.localizedDescription)")
                completion(true)
                return
            }
            guard let data = data else {
                print("❌ Perspective API returned no data")
                completion(true)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("✅ Perspective API response: \(json)")
                    if let attributeScores = json["attributeScores"] as? [String: Any],
                       let toxicity = attributeScores["TOXICITY"] as? [String: Any],
                       let summaryScore = toxicity["summaryScore"] as? [String: Any],
                       let value = summaryScore["value"] as? Double {
                        print("Toxicity Score: \(value)")
                        completion(value < 0.5)
                    } else {
                        print("⚠️ Unexpected Perspective API response format")
                        completion(true)
                    }
                }
            } catch {
                print("❌ Perspective API JSON parse error: \(error)")
                completion(true)
            }
        }.resume()
    }

    func showBadCommentAlert() {
        showToxicityAlert = true
    }

    private var authorInitials: String {
        nameInitials(from: post.authorUsername)
    }

    private func nameInitials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined()
    }

    func listenToLikeCount() {
        db.collection("posts").document(post.postId).addSnapshotListener { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            likeCount = data["likeCount"] as? Int ?? 0

            if let likedBy = data["likedBy"] as? [String],
               let userUID = Auth.auth().currentUser?.uid {
                isLiked = likedBy.contains(userUID)
            }
        }
    }
}

extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

struct CommentInputCard: View {

    @Binding var text: String
    var placeholder: String = ""
    var multiline: Bool = false
    var editable: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.3))
                        .padding(14)
                }
                if multiline {
                    TextEditor(text: $text)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(Color.white.opacity(0.1).cornerRadius(12))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .disabled(!editable)
                } else {
                    TextField("", text: $text)
                        .padding(12)
                        .background(Color.white.opacity(0.1).cornerRadius(12))
                        .foregroundColor(.white)
                        .disabled(!editable)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
}
