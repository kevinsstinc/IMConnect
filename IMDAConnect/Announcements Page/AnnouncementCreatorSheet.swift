//
//  AnnouncementCreatorSheet.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 13/6/25.
//
import SwiftUI

struct AnnouncementCreatorSheet: View {
    @ObservedObject var manager: AnnouncementsManager
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var author = ""
    @State private var tagsText = ""
    @State private var pdfURL = ""
    @State private var pulse = false
    @Environment(\.colorScheme) var colorScheme


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

            ScrollView {
                VStack(spacing: 24) {
                    Text("New Announcement")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    CreateInputCard(title: "Title", text: $title, placeholder: "Enter announcement title")
                    CreateInputCard(title: "Content", text: $content, placeholder: "Enter announcement content", multiline: true)
                    CreateInputCard(title: "Author", text: $author, placeholder: "Enter author name")
                    CreateInputCard(title: "Tags (comma separated)", text: $tagsText, placeholder: "e.g. urgent, info")
                    CreateInputCard(title: "PDF URL (optional)", text: $pdfURL, placeholder: "Paste PDF link here")

                    Button(action: {
                        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                        let newAnnouncement = Announcement(
                            title: title,
                            content: content,
                            date: Date(),
                            tags: tags,
                            author: author,
                            pdfURL: pdfURL.isEmpty ? nil : pdfURL.lowercased()
                        )
                        do {
                            _ = try manager.db.collection("announcements").addDocument(from: newAnnouncement)
                            
                        } catch {
                            print("Error saving announcement: \(error)")
                        }
                        dismiss()
                    }) {
                        Text("Create Announcement")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.gradient.opacity(0.2))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .onAppear { pulse = true }
    }
}
