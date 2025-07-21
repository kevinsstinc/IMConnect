//
//  AuthorProfilePage.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 19/7/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthorProfilePage: View {
    let userUID: String

    @State private var name: String = "Anonymous User"
    @State private var role: String = "Your Role"
    @State private var school: String = "Your School"
    @State private var about: String = "Hey there! I am a user of IMConnect!"
    @State private var showEditSheet: Bool = false
    @Namespace private var animation
    @State private var isLoading = false
    @State private var pulse = false
    @State private var userEmail: String = ""
    @State private var showSignOutAlert = false
    @State private var isSigningOut = false
    @AppStorage("isUserLoggedIn") var isUserLoggedIn: Bool = false

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
                    VStack(spacing: 30) {
                        Spacer().frame(height: 40)
                        Circle()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: 160, height: 160)
                            .shadow(color: .purple.opacity(0.4), radius: 15, x: 0, y: 5)
                            .scaleEffect(pulse ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                            .matchedGeometryEffect(id: "profilePic", in: animation)
                            .overlay(
                                Text(nameInitials())
                                    .font(.system(size: 64, weight: .bold))
                                    .foregroundStyle(Color.purple.opacity(0.8))
                            )

                        if isLoading {
                            loadingView()
                        } else {
                            VStack(spacing: 6) {
                                Text(name).font(.largeTitle.bold()).foregroundStyle(.white).shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                Text(role).font(.title3).foregroundStyle(.white.opacity(0.85))
                                Text(school).font(.title3.weight(.medium)).foregroundStyle(.white.opacity(0.85))
                            }
                            .padding(.horizontal)
                        }

                        Text("Email")
                            .font(.title2.bold())
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)

                        Text(userEmail)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        DividerLine()

                        Text("About")
                            .font(.title2.bold())
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)

                        Text(about)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
//                        Button(action: {
//                            startChat(with: userUID)
//                        }) {
//                            HStack {
//                                Image(systemName: "bubble.left.and.bubble.right.fill")
//                                    .font(.title2)
//                                Text("Message")
//                                    .font(.headline)
//                            }
//                            .foregroundStyle(.white)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.white.opacity(0.2))
//                            .cornerRadius(14)
//                            .shadow(color: .purple.opacity(0.3), radius: 5, x: 0, y: 4)
//                            .padding(.horizontal)
//                            .padding(.bottom, 10)
//                        }
//                        .buttonStyle(ScaleButtonStyle())



                    }
                    .padding(.bottom, 90)
                }
                .onAppear {
                    pulse = true
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { isLoading = false }
                    }
                    loadUserProfile()
                }
            }
        }
    }
    

    func sendFriendRequest(to targetUID: String) {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        db.collection("friendRequests")
            .document(targetUID)
            .collection("requests")
            .document(currentUID)
            .setData([
                "senderID": currentUID,
                "senderName": currentUser.displayName ?? "Unknown",
                "senderEmail": currentUser.email ?? "",
                "timestamp": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    print("❌ Failed to send friend request: \(error.localizedDescription)")
                } else {
                    print("✅ Friend request sent to \(targetUID)")
                }
            }
    }

    func nameInitials() -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined()
    }

    @ViewBuilder
    func loadingView() -> some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 160, height: 24)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 120, height: 18)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 140, height: 18)
        }
        .padding(.top, 6)
    }

    func loadUserProfile() {
        let db = Firestore.firestore()
        db.collection("users").document(userUID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                name = data?["name"] as? String ?? ""
                role = data?["role"] as? String ?? ""
                school = data?["school"] as? String ?? ""
                about = data?["about"] as? String ?? ""
                userEmail = data?["email"] as? String ?? ""
            } else {
                print("⚠️ No profile found for userUID: \(userUID)")
            }
        }
    }

    @ViewBuilder
    func DividerLine() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(.white.opacity(0.1))
            .frame(width: 370, height: 2)
    }
}
