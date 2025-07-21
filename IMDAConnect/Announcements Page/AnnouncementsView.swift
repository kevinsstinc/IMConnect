//
//  AnnouncementsView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 13/6/25.
//

import SwiftUI
import FirebaseFirestore

struct Announcement: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var content: String
    var date: Date
    var tags: [String]
    var author: String
    var pdfURL: String?
}
class AnnouncementsManager: ObservableObject {
    @Published var announcements: [Announcement] = []
    let db = Firestore.firestore()
    
    init() {
        fetchAnnouncements()
    }
    
    func fetchAnnouncements() {
        db.collection("announcements")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.announcements = docs.compactMap { try? $0.data(as: Announcement.self) }
            }
    }
}


struct AnnouncementsView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var manager = AnnouncementsManager()
    @StateObject private var pinsManager = UserPinsManager()
    @State private var selectedTag: String? = nil
    @State private var searchText: String = ""
    @State private var pulse = false
    @State private var showCreator = false
    
    var allTags: [String] {
        let tags = manager.announcements.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
    
    var filteredAnnouncements: [Announcement] {
        manager.announcements
            .filter {
                (selectedTag == nil || $0.tags.contains(selectedTag!)) &&
                (searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText))
            }
            .sorted {
                let pin0 = pinsManager.isPinned($0.id)
                let pin1 = pinsManager.isPinned($1.id)
                if pin0 == pin1 {
                    return $0.date > $1.date
                }
                return pin0 && !pin1
            }
    }
    
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
                    VStack(alignment: .leading, spacing: 28) {
                        HStack {
                            Text("Announcements")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                            if userManager.isAdmin {
                                Button(action: { showCreator = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.white)
                                }
                                .sheet(isPresented: $showCreator) {
                                    AnnouncementCreatorSheet(manager: manager)
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 32)
                        
                        SearchBar(searchText: $searchText)
                            .padding(.horizontal, 28)
                        
                        if !allTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(allTags, id: \.self) { tag in
                                        Text(tag.capitalized)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(selectedTag == tag ? Color.purple.opacity(0.6) : Color.white.opacity(0.1))
                                            .foregroundStyle(.white)
                                            .cornerRadius(14)
                                            .onTapGesture {
                                                withAnimation {
                                                    selectedTag = selectedTag == tag ? nil : tag
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 28)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(filteredAnnouncements) { ann in
                                NavigationLink(destination: AnnouncementDetailView(announcement: ann)) {
                                    AnnouncementCard(
                                        announcement: ann,
                                        isPinned: pinsManager.isPinned(ann.id)
                                    )
                                    .contextMenu {
                                        Button {
                                            pinsManager.togglePin(ann.id)
                                        } label: {
                                            Label(
                                                pinsManager.isPinned(ann.id) ? "Unpin" : "Pin",
                                                systemImage: pinsManager.isPinned(ann.id) ? "pin.slash" : "pin"
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 40)
                        .padding(.bottom, 100)
                    }
                }
                .onAppear {
                    pulse = true
                    userManager.fetchCurrentUserAdminStatus()
                }
            }
        }
    }
}


#Preview {
    AnnouncementsView()
}


