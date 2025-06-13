//
//  AdminEventView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 12/6/25.
//
import SwiftUI
import FirebaseFirestore
import PhotosUI


struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var location: String
    var date: Date
    var createdAt: Date
    var tags: [String]
}

class FirestoreManager: ObservableObject {
    @Published var events: [Event] = []
    private var db = Firestore.firestore()

    init() {
        fetchEvents()
    }

    func fetchEvents() {
        db.collection("events")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.events = documents.compactMap { try? $0.data(as: Event.self) }
            }
    }

    func createEvent(_ event: Event) {
        do {
            _ = try db.collection("events").addDocument(from: event)
        } catch {
            print("❌ Error creating event: \(error.localizedDescription)")
        }
    }
}

struct AdminEventView: View {
    @State private var pulse = false
    @State private var adminSheet = false
    @StateObject private var firestore = FirestoreManager()
    @State private var selectedEvent: Event? = nil
    @State private var selectedTag: String? = nil
    @State private var showDetailSheet = false

    var filteredEvents: [Event] {
        guard let tag = selectedTag else { return firestore.events }
        return firestore.events.filter { $0.tags.contains(tag) }
    }

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
                VStack(alignment: .leading, spacing: 28) {
                    HStack {
                        Text("Events")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Button {
                            adminSheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                        .sheet(isPresented: $adminSheet) {
                            AdminEventCreator(firestore: firestore)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 32)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(Set(firestore.events.flatMap { $0.tags })), id: \.self) { tag in
                                Text(tag.capitalized)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedTag == tag ? Color.purple.opacity(0.6) : Color.white.opacity(0.1))
                                    .foregroundColor(.white)
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

                    Text("Featured")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)
                        .padding(.bottom, -100)

                    if !filteredEvents.isEmpty {
                        TabView {
                            ForEach(filteredEvents.prefix(3)) { event in
                                EventCard(event: event)
                                    .onTapGesture {
                                        selectedEvent = event
                                        showDetailSheet = true
                                    }
                            }
                        }
                        .frame(height: 240)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .padding(.horizontal, 28)
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(filteredEvents.dropFirst(3)) { event in
                            EventCard(event: event)
                                .onTapGesture {
                                    selectedEvent = event
                                    showDetailSheet = true
                                }
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
                }
            }
            .onAppear { pulse = true }
        }
        .sheet(item: $selectedEvent) { event in
            AdminEventDetailSheet(event: event)
        }
    }
}

struct EventCard: View {
    var event: Event

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text(event.date, style: .date)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
                Text(event.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                HStack {
                    ForEach(event.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.15))
                            .foregroundColor(.white.opacity(0.9))
                            .cornerRadius(8)
                    }
                }
            }
            Spacer()
        }
        .padding(24)
        .frame(width: 340, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
}

struct AdminEventDetailSheet: View, Identifiable {
    let id = UUID()
    var event: Event
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Event Details")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 20)

                CreateInputCard(title: "Event Name", text: .constant(event.name), placeholder: "", editable: false)
                CreateInputCard(title: "Event Description", text: .constant(event.description), placeholder: "", multiline: true, editable: false)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Event Date")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline.weight(.medium))
                        .padding(.leading, 4)
                    Text(event.date.formatted(date: .long, time: .omitted))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.1).cornerRadius(12))
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.12)))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))

                CreateInputCard(title: "Event Location", text: .constant(event.location), placeholder: "", editable: false)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Tags")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.subheadline.weight(.medium))
                        .padding(.leading, 4)
                    HStack {
                        ForEach(event.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.15))
                                .foregroundColor(.white.opacity(0.9))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.12)))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))

                Button("Close") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.gradient.opacity(0.2))
                .cornerRadius(14)
                .padding(.horizontal)
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 74/255, green: 31/255, blue: 91/255),
                    Color(red: 100/255, green: 42/255, blue: 122/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct AdminEventCreator: View {
    @State private var eventName = ""
    @State private var eventDescription = ""
    @State private var eventDate = Date()
    @State private var eventLocation = ""
    @State private var tagsText = ""
    @Environment(\.dismiss) var dismiss
    var firestore: FirestoreManager
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
                    Text("Create New Event")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    CreateInputCard(title: "Event Name", text: $eventName, placeholder: "Enter event name")
                    CreateInputCard(title: "Event Description", text: $eventDescription, placeholder: "Enter event description", multiline: true)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Event Date")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline.weight(.medium))
                            .padding(.leading, 4)
                        DatePicker("", selection: $eventDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .environment(\.colorScheme, .light)
                            .padding()
                            .background(Color.white.opacity(0.1).cornerRadius(12))
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.12)))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))

                    CreateInputCard(title: "Event Location", text: $eventLocation, placeholder: "Enter event location")
                    CreateInputCard(title: "Tags (comma separated)", text: $tagsText, placeholder: "e.g. tech, photography")
                    
                    Button(action: {
                        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                        let event = Event(
                            name: eventName,
                            description: eventDescription,
                            location: eventLocation,
                            date: eventDate,
                            createdAt: Date(),
                            tags: tags
                        )
                        firestore.createEvent(event)
                        dismiss()
                    }) {
                        Text("Create Event")
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

struct CreateInputCard: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var multiline: Bool = false
    var editable: Bool = true

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


#Preview {
    AdminEventView()
}
