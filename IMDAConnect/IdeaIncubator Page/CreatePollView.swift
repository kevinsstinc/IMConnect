//
//  CreatePollView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 7/7/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreatePollView: View {
    @Environment(\.dismiss) var dismiss
    var onComplete: () -> Void

    @State private var question = ""
    @State private var options: [String] = ["", ""]
    @State private var description = ""
    @State private var isUploading = false
    @State private var userName: String = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

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

            ScrollView {
                VStack(spacing: 24) {
                    Text("New Idea Poll")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 20)

                    CreateInputCard(
                        title: "Idea",
                        text: $question,
                        placeholder: "Describe your idea...",
                        multiline: true
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Options")
                            .font(.headline)
                            .foregroundStyle(.white)

                        ForEach(options.indices, id: \.self) { idx in
                            HStack {
                                TextField("Option \(idx + 1)", text: $options[idx])
                                    .padding(10)
                                    .background(Color.white.opacity(0.1).cornerRadius(10))
                                    .foregroundStyle(.white)

                                if options.count > 2 {
                                    Button(action: { options.remove(at: idx) }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                        }

                        Button(action: {
                            if options.count < 6 {
                                options.append("")
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Option")
                            }
                            .foregroundStyle(.white)
                        }
                        .disabled(options.count >= 6)
                    }
                    
                    CreateInputCard(
                        title: "Description",
                        text: $description,
                        placeholder: "Add more context (optional)",
                        multiline: true
                    )

                    Button(action: {
                        moderateAndCreatePoll()
                    }) {
                        Text(isUploading ? "Posting..." : "Post Poll")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isUploading ? Color.gray : Color.purple.opacity(0.25))
                            .cornerRadius(12)
                    }
                    .disabled(isUploading || question.trimmingCharacters(in: .whitespaces).isEmpty || options.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty }))
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .onAppear {
            fetchUserProfile()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Warning", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }


    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { doc, _ in
            let data = doc?.data()
            userName = data?["name"] as? String ?? (Auth.auth().currentUser?.displayName ?? "Anonymous")
        }
    }

    func moderateAndCreatePoll() {
        print("🛡️ Moderating poll text...")

        isUploading = true
        let allTexts = [question, description] + options

        checkTextsWithPerspectiveAPI(allTexts) { allTextsClean in
            DispatchQueue.main.async {
                if allTextsClean {
                    print("✅ All text passed moderation, uploading poll")
                    createPoll()
                } else {
                    alertMessage = "Your poll contains inappropriate or toxic language. Please revise it."
                    showAlert = true
                    isUploading = false
                }
            }
        }
    }

    func checkTextsWithPerspectiveAPI(_ texts: [String], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var isClean = true

        for text in texts where !text.trimmingCharacters(in: .whitespaces).isEmpty {
            group.enter()
            checkTextWithPerspectiveAPI(text) { textIsClean in
                if !textIsClean {
                    isClean = false
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(isClean)
        }
    }

    func checkTextWithPerspectiveAPI(_ text: String, completion: @escaping (Bool) -> Void) {
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
            "comment": ["text": text],
            "languages": ["en"],
            "requestedAttributes": ["TOXICITY": [:]]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestDict) else {
            print("❌ Failed to serialize JSON")
            completion(true)
            return
        }

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
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let attributeScores = json["attributeScores"] as? [String: Any],
                   let toxicity = attributeScores["TOXICITY"] as? [String: Any],
                   let summaryScore = toxicity["summaryScore"] as? [String: Any],
                   let value = summaryScore["value"] as? Double {
                    print("Toxicity Score: \(value) for text: \"\(text)\"")
                    completion(value < 0.5)
                } else {
                    print("⚠️ Unexpected Perspective API response format")
                    completion(true)
                }
            } catch {
                print("❌ Perspective API JSON parse error: \(error)")
                completion(true)
            }
        }.resume()
    }

    func createPoll() {
        guard let user = Auth.auth().currentUser else { return }
        let pollDoc = Firestore.firestore().collection("idea_polls").document()
        let pollData: [String: Any] = [
            "pollId": pollDoc.documentID,
            "authorUID": user.uid,
            "authorName": userName,
            "question": question,
            "options": options,
            "votes": [String: Int](),
            "votedBy": [String: Int](),
            "timestamp": Timestamp(),
            "description": description
        ]
        pollDoc.setData(pollData) { error in
            DispatchQueue.main.async {
                isUploading = false
                if error == nil {
                    print("✅ Poll successfully saved")
                    dismiss()
                    onComplete()
                } else {
                    print("❌ Firestore save error: \(error?.localizedDescription ?? "Unknown error")")
                    alertMessage = "Failed to upload poll. Please try again."
                    showAlert = true
                }
            }
        }
    }
}

