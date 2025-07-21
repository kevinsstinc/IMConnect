//
//  CommentModel.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/6/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SDWebImageSwiftUI

struct Comment: Identifiable {
    let id: String
    let authorUID: String
    let authorName: String
    let authorProfileURL: String
    let content: String
    let timestamp: Timestamp
    
    init(from dict: [String: Any], id: String) {
        self.id = id
        self.authorUID = dict["authorUID"] as? String ?? ""
        self.authorName = dict["authorName"] as? String ?? "Unknown"
        self.authorProfileURL = dict["authorProfileURL"] as? String ?? ""
        self.content = dict["content"] as? String ?? ""
        self.timestamp = dict["timestamp"] as? Timestamp ?? Timestamp()
    }
}


