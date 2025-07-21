//
//  Poll Model.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 7/7/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Poll: Identifiable {
    var id: String { pollId }
    let pollId: String
    let authorUID: String
    let authorName: String
    let question: String
    let options: [String]
    let votes: [String: Int]
    let votedBy: [String: Int]
    let timestamp: Timestamp
    let description: String

    init(from dict: [String: Any], id: String) {
        self.pollId = id
        self.authorUID = dict["authorUID"] as? String ?? ""
        self.authorName = dict["authorName"] as? String ?? "Unknown"
        self.question = dict["question"] as? String ?? ""
        self.options = dict["options"] as? [String] ?? []
        self.votes = dict["votes"] as? [String: Int] ?? [:]
        self.votedBy = dict["votedBy"] as? [String: Int] ?? [:]
        self.timestamp = dict["timestamp"] as? Timestamp ?? Timestamp()
        self.description = dict["description"] as? String ?? ""
    }
}
