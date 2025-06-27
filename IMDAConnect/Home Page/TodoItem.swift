//
//  TodoItem.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 26/6/25.
//
import SwiftUI

struct TodoItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var text: String
    var isDone: Bool = false
}
