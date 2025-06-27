//
//  UserPinsManager.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 27/6/25.
//
import SwiftUI

class UserPinsManager: ObservableObject {
    @Published var pinnedIDs: Set<String> = []
    private let key = "userPinnedAnnouncementIDs"
    
    init() {
        load()
    }
    
    func load() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            pinnedIDs = Set(saved)
        }
    }
    
    func save() {
        UserDefaults.standard.set(Array(pinnedIDs), forKey: key)
    }
    
    func isPinned(_ id: String?) -> Bool {
        guard let id else { return false }
        return pinnedIDs.contains(id)
    }
    
    func togglePin(_ id: String?) {
        guard let id else { return }
        if pinnedIDs.contains(id) {
            pinnedIDs.remove(id)
        } else {
            pinnedIDs.insert(id)
        }
        save()
    }
}
