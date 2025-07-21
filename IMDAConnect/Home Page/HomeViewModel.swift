//
//  HomeViewModel.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 26/6/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import UserNotifications
@MainActor
class HomeViewModel: ObservableObject {
    @Published var todoItems: [TodoItem] = []
    @Published var userName: String = "User"
    @Published var dailyQuote: String = ""
    
    private let db = Firestore.firestore()
    
    func toggleTodo(_ item: TodoItem) {
        if let idx = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[idx].isDone.toggle()
            saveTodosToFirestore()
        }
    }
    
    func deleteTodo(_ item: TodoItem) {
        todoItems.removeAll { $0.id == item.id }
        saveTodosToFirestore()
        scheduleDailyTaskReminder()
    }
    
    func saveTodosToFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dictArr = todoItems.map { ["id": $0.id.uuidString, "text": $0.text, "isDone": $0.isDone] }
        db.collection("todos").document(uid).setData(["items": dictArr]) { error in
            if let error = error {
                print("Error saving todos: \(error.localizedDescription)")
            }
        }
    }
    
    func loadTodosFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("todos").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error loading todos: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data(), let items = data["items"] as? [[String: Any]] {
                self.todoItems = items.compactMap { dict in
                    guard let idStr = dict["id"] as? String,
                          let text = dict["text"] as? String,
                          let isDone = dict["isDone"] as? Bool,
                          let uuid = UUID(uuidString: idStr) else { return nil }
                    return TodoItem(id: uuid, text: text, isDone: isDone)
                }
                self.scheduleDailyTaskReminder()

            }
            
        }
    }
    func requestNotificationPermissionAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.scheduleDailyTaskReminder()
            } else {
                print("🔕 Notification permission not granted.")
            }
        }
    }

    func scheduleDailyTaskReminder() {
        print("Scheduling daily task reminder for 6 PM...")

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyTaskReminder"])
        print("Removed existing notifications with ID dailyTaskReminder.")

        let unfinishedTasks = self.todoItems.filter { !$0.isDone }
        print("Unfinished tasks count: \(unfinishedTasks.count)")

        guard !unfinishedTasks.isEmpty else {
            print("No unfinished tasks, no notification scheduled.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Don't forget your tasks!"
        content.body = "You still have \(unfinishedTasks.count) task(s) to finish today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 18  
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyTaskReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Daily task reminder scheduled for 6 PM.")
            }
        }
    }


    func fetchUserName() {
        guard let user = Auth.auth().currentUser else { return }
        db.collection("users").document(user.uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["name"] as? String ?? "User"
            }
        }
    }
}
