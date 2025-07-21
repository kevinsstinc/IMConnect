//
//  IdeaChatbotView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 19/7/25.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct IdeaChatbotView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var showTypingIndicator = false

    private let quickPrompts = [
        "Give me startup ideas",
        "How to improve this app?",
        "Brainstorm 5 event ideas"
    ]

    var body: some View {
        ZStack {
            Color(red: 245/255, green: 240/255, blue: 250/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("AI Idea Assistant")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 74/255, green: 31/255, blue: 91/255))
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color(red: 74/255, green: 31/255, blue: 91/255))
                    }
                }
                .padding()
                
                Divider()

                if messages.isEmpty && !isLoading {
                    Spacer()
                    Text("What can I help with?")
                        .font(.title.weight(.bold))
                        .foregroundColor(.black.opacity(0.8))
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(messages) { msg in
                                    ChatBubble(message: msg)
                                        .id(msg.id)
                                }
                                if showTypingIndicator {
                                    TypingIndicator()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .onChange(of: messages.count) { _ in
                                withAnimation {
                                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                if messages.isEmpty {
                    HStack(spacing: 10) {
                        ForEach(quickPrompts, id: \.self) { prompt in
                            Button(action: {
                                inputText = prompt
                            }) {
                                Text(prompt)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 74/255, green: 31/255, blue: 91/255))
                                    .frame(height: 60)
                                    .padding(.horizontal, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    )
                            }
                        }

                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                HStack(spacing: 10) {
                    TextField("Ask anything...", text: $inputText)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .frame(width: 36, height: 36)
                    } else {
                        Button(action: sendToAI) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.purple)
                                .clipShape(Circle())
                        }
                        .disabled(inputText.isEmpty)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 85)
                .background(Color(red: 245/255, green: 240/255, blue: 250/255).opacity(0.8))
            }
        }
        .navigationBarHidden(true)
    }

    func sendToAI() {
        guard !inputText.isEmpty else { return }
        
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        let userText = inputText
        messages.append(ChatMessage(text: userText, isUser: true))
        inputText = ""
        isLoading = true
        showTypingIndicator = true

        let prompt = """
        You are an upbeat, highly creative AI brainstorming assistant who chats naturally with students to help them come up with innovative, practical, and inspiring ideas for projects, events, apps, startups, or ways to improve existing systems. 
        Your tone must feel friendly, conversational, and motivational — like a supportive peer or mentor who genuinely wants to collaborate, never robotic or overly formal. 
        Respond as if you’re chatting, engaging with the student while delivering high-quality ideas.

        Your objectives:
        1. Engage the student like a real conversation partner: Respond fluidly, using natural language, occasional follow-up questions, and conversational phrases without sounding scripted.
        2. Generate actionable, original ideas: Always produce 3–5 concrete ideas in a numbered list (1., 2., 3., etc.). Each idea must be:
           - Short (1–2 sentences)
           - Realistic for a student to implement
           - Distinct and not repetitive
           - Creative (avoid obvious or cliché suggestions)
        3. Keep a mix of scales and angles: Some ideas can be quick hacks, some tech-driven, others community-focused or event-based.
        4. Avoid filler: Don’t start with phrases like “Here are some ideas” — begin with the first idea right away.
        5. End with a quick, engaging nudge to keep the conversation going, like:
           - “Which of these do you feel like running with?”
           - “Want me to turn one into a step-by-step plan?”
        6. Formatting rules:
           - No markdown, no asterisks, no bullet points, and no code block formatting in the output.
           - Each idea starts with its number and period (e.g., 1., 2.) and appears on a new line.
           - Maintain the conversational tone throughout, even while listing ideas.

        Student’s request: \(userText)
        """


        Task {
            if let reply = await callMistralAPI(prompt: prompt) {
                messages.append(ChatMessage(text: reply, isUser: false))
            } else {
                messages.append(ChatMessage(text: "I couldn’t come up with ideas right now. Try again later.", isUser: false))
            }
            isLoading = false
            showTypingIndicator = false
        }
    }

}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(message.isUser ? Color.purple.opacity(0.85) : Color.white)
                .foregroundColor(message.isUser ? .white : .black)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal, 4)
    }
}


struct TypingIndicator: View {
    @State private var animate = false

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animate ? 1 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(i) * 0.2),
                            value: animate
                        )
                }
            }
            Spacer()
        }
        .onAppear { animate = true }
        .padding(.vertical, 8)
        .padding(.leading, 16)
    }
}

func callMistralAPI(prompt: String) async -> String? {
    guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else { return nil }

    let payload: [String: Any] = [
        "model": "mistralai/mistral-small-3.2-24b-instruct:free",
        "messages": [["role": "user", "content": prompt]]
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer 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", forHTTPHeaderField: "Authorization")

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let msg = choices.first?["message"] as? [String: Any],
           let content = msg["content"] as? String {
            return content
        }
    } catch {
        print("❌ API error: \(error.localizedDescription)")
    }
    return nil
}
