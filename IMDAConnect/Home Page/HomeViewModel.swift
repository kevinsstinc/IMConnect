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
    
    func fetchDailyQuote() {
        // Replace with API if needed
        dailyQuote = "Stay curious, stay learning, stay growing."
    }
}
