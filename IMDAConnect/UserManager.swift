//
//  UserManager.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 15/6/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserManager: ObservableObject {
    @Published var isAdmin: Bool = false
    private var db = Firestore.firestore()

    func fetchCurrentUserAdminStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, _ in
            if let data = snapshot?.data(), let admin = data["isAdmin"] as? Bool {
                DispatchQueue.main.async {
                    self.isAdmin = admin
                }
            }
        }
    }
}
