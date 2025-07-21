//
//  HomeView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 26/6/25.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @StateObject private var homeManager = AnnouncementsManager()
    @State private var pulse = false
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingTodoSheet = false
    @State private var showDeleteAlert = false
    @State private var todoToDelete: TodoItem? = nil
    @State private var carouselIndex = 0

    private let db = Firestore.firestore()
    private var currentUID: String? { Auth.auth().currentUser?.uid }

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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 36) {
                        // Welcome Section
                        Spacer(minLength: 24)
                        HStack {
                            Text("Welcome back, \(viewModel.userName)")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                            Spacer()
                        }
                        .padding(.horizontal, 28)

                        // Announcements Section
                        if !homeManager.announcements.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Latest Announcements")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.leading, 24)
                                TabView(selection: $carouselIndex) {
                                    ForEach(Array(homeManager.announcements.prefix(3).enumerated()), id: \.offset) { idx, ann in
                                        NavigationLink(destination: AnnouncementDetailView(announcement: ann)) {
                                            AnnouncementCard(announcement: ann)
                                                .padding(.horizontal, 24)
                                        }
                                        .tag(idx)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .frame(height: 180)
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                            }
                            .padding(.bottom, 12)
                        }

                        // To-Do List Section
                        toDoSection
                    }
                    .padding(.bottom, 60)
                }
                .onAppear {
                    pulse = true
                    viewModel.loadTodosFromFirestore()
                    viewModel.fetchUserName()
                    viewModel.requestNotificationPermissionAndSchedule()
                }
            }
        }
    }

    // MARK: To-Do Section
    private var toDoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("To-Do List")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                Button { isShowingTodoSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 28)
            if viewModel.todoItems.isEmpty {
                Text("No tasks yet. Add your first to-do!")
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.todoItems) { item in
                        TodoRow(
                            item: item,
                            onToggle: { viewModel.toggleTodo(item) },
                            onDelete: {
                                todoToDelete = item
                                showDeleteAlert = true
                            }
                        )
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete To-Do"),
                                message: Text("Are you sure you want to delete this to-do?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    if let item = todoToDelete {
                                        viewModel.deleteTodo(item)
                                    }
                                    todoToDelete = nil
                                },
                                secondaryButton: .cancel {
                                    todoToDelete = nil
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 6)
            }
        }
        .sheet(isPresented: $isShowingTodoSheet) {
            AddTodoSheet { newTodo in
                let item = TodoItem(text: newTodo)
                viewModel.todoItems.append(item)
                viewModel.saveTodosToFirestore()
            }
        }
    }
}
