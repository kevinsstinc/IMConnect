//
//  EditProfileSheet.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/5/25.
//

import SwiftUI

struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var role: String
    @Binding var school: String
    @Binding var about: String

    @Environment(\.dismiss) var dismiss
    @State private var pulse = false
    @State private var isCheckingContent = false
    @State private var moderationFailed = false
    @State private var alertMessage = ""

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
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: pulse)

            VStack {
                ScrollView {
                    VStack(spacing: 25) {
                        Text("Edit Profile")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        ProfileInputCard(title: "Name", text: $name)
                        ProfileInputCard(title: "Role", text: $role)
                        ProfileInputCard(title: "School", text: $school)
                        ProfileInputCard(title: "About", text: $about, placeholder: "Write about yourself...", multiline: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }

                Button {
                    print("📤 Save Changes tapped")
                    runModerationChecks()
                } label: {
                    Text(isCheckingContent ? "Saving..." : "Save Changes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isCheckingContent ? Color.gray : Color.purple.opacity(0.25))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
                .disabled(isCheckingContent)
            }

            if isCheckingContent {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 14) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.4)
                            Text("Checking content...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    )
            }
        }
        .onAppear {
            withAnimation {
                pulse.toggle()
            }
        }
        .alert("Inappropriate content detected", isPresented: $moderationFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    func runModerationChecks() {
        isCheckingContent = true
        Task {
            let fieldsToCheck = [
                ("Name", name),
                ("Role", role),
                ("School", school),
                ("About", about)
            ]

            for (fieldName, text) in fieldsToCheck {
                let passed = await checkTextWithPerspectiveAPI(text)
                if !passed {
                    DispatchQueue.main.async {
                        isCheckingContent = false
                        moderationFailed = true
                        alertMessage = "\(fieldName) contains inappropriate or toxic language. Please revise it."
                    }
                    return
                }
            }

            DispatchQueue.main.async {
                isCheckingContent = false
                dismiss()
            }
        }
    }

    func checkTextWithPerspectiveAPI(_ text: String) async -> Bool {
        guard !text.isEmpty else {
            return true 
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
            return true
        }

        let requestDict: [String: Any] = [
            "comment": ["text": text],
            "languages": ["en"],
            "requestedAttributes": ["TOXICITY": [:]]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestDict) else {
            print("❌ Failed to serialize JSON")
            return true
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let attributeScores = json["attributeScores"] as? [String: Any],
               let toxicity = attributeScores["TOXICITY"] as? [String: Any],
               let summaryScore = toxicity["summaryScore"] as? [String: Any],
               let score = summaryScore["value"] as? Double {
                print("🛡️ Moderation result for '\(text)': \(score)")
                return score < 0.5
            }
        } catch {
            print("❌ Perspective API error: \(error.localizedDescription)")
        }
        return true
    }
}



struct ProfileInputCard: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var multiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline.weight(.medium))

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
                        .background(glassyBackground)
                        .cornerRadius(16)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                } else {
                    TextField(title, text: $text)
                        .padding(12)
                        .background(glassyBackground)
                        .cornerRadius(16)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.12))
                .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 6)
                .shadow(color: Color.pink.opacity(0.3), radius: 8, x: 3, y: 3)
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
    }

    private var glassyBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.1))
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}


