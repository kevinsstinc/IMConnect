//
//  PostModel.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/6/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SDWebImageSwiftUI

struct Post: Identifiable {
    var id: String { postId }
    let postId: String
    let authorUID: String
    let authorUsername: String
    let authorProfileURL: String
    let imageURL: String
    let caption: String
    let timestamp: Timestamp
    let likeCount: Int
    let likedBy: [String]?
    
    init(from dict: [String: Any], id: String) {
        self.postId = id
        self.authorUID = dict["authorUID"] as? String ?? ""
        self.authorUsername = dict["authorUsername"] as? String ?? "Unknown"
        self.authorProfileURL = dict["authorProfileURL"] as? String ?? ""
        self.imageURL = dict["imageURL"] as? String ?? ""
        self.caption = dict["caption"] as? String ?? ""
        self.timestamp = dict["timestamp"] as? Timestamp ?? Timestamp()
        self.likeCount = dict["likeCount"] as? Int ?? 0
        self.likedBy = dict["likedBy"] as? [String]
    }
}
