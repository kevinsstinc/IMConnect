//
//  CreatePostView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/6/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import PhotosUI
import SDWebImageSwiftUI
import Foundation

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var caption = ""
    @State private var selectedImage: UIImage?
    @State private var imageData: Data?
    @State private var isUploading = false
    @State private var pickerItem: PhotosPickerItem?
    var onComplete: () -> Void

    @State private var userName: String = ""
    @State private var userProfileURL: String = ""
    @State private var showAlert = false
    @State private var showAlert2 = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 74/255, green: 31/255, blue: 91/255),
                    Color(red: 100/255, green: 42/255, blue: 122/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Text("New Post")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .padding(.top, 20)

                    Group {
                        if let img = selectedImage {
                            PhotosPicker(selection: $pickerItem, matching: .images) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 220)
                                    .cornerRadius(14)
                            }
                        } else {
                            PhotosPicker(selection: $pickerItem, matching: .images) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 220)
                                    .overlay(Text("Select Image")
                                                .foregroundColor(.white.opacity(0.5)))
                            }
                        }
                    }
                    .onChange(of: pickerItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                print("✅ Image selected")
                                selectedImage = uiImage
                                imageData = data
                            } else {
                                print("❌ Failed to load selected image")
                            }
                        }
                    }

                    CreateInputCard(title: "Caption", text: $caption, placeholder: "Write your post...", multiline: true)

                    Button {
                        print("📤 Post button tapped")
                        moderateAndUploadPost()
                    } label: {
                        Text(isUploading ? "Posting..." : "Post")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                (isUploading || selectedImage == nil || caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    ? Color.gray
                                    : Color.purple.opacity(0.25)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(isUploading || selectedImage == nil || caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal)

                }
                .padding()
            }
        }
        .onAppear {
            print("Fetching user profile...")
            fetchUserProfile()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    print("❌ Post creation cancelled")
                    dismiss()
                }
            }
        }
        .alert("Warning", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { doc, error in
            if let error = error {
                print("❌ Failed to fetch user profile: \(error.localizedDescription)")
            }
            let data = doc?.data()
            userName = data?["name"] as? String ?? (Auth.auth().currentUser?.displayName ?? "Anonymous")
            userProfileURL = data?["profileURL"] as? String ?? (Auth.auth().currentUser?.photoURL?.absoluteString ?? "")
            print("✅ User profile fetched: \(userName)")
        }
    }

    func moderateAndUploadPost() {
        print("🛡️ Starting moderation: image first")
        isUploading = true

        moderateImage { isImageClean in
            DispatchQueue.main.async {
                if isImageClean {
                    print("✅ Image passed moderation, now checking text")

                    checkTextWithPerspectiveAPI(caption) { isTextClean in
                        DispatchQueue.main.async {
                            if isTextClean {
                                print("✅ Text passed moderation, uploading post")
                                uploadPost()
                            } else {
                                alertMessage = "Your post contains inappropriate or toxic language. Please revise it."
                                showAlert = true
                                isUploading = false
                            }
                        }
                    }

                } else {
                    alertMessage = "The selected image contains inappropriate content. Please choose another image."
                    showAlert = true
                    isUploading = false
                }
            }
        }
    }



    func moderateImage(completion: @escaping (Bool) -> Void) {
        guard let imageData = self.imageData else {
            print("❌ No image data to moderate")
            completion(false)
            return
        }

        print("🛡️ Sending image to Sightengine for moderation...")

        let apiUser = "API_USER_HERE"
        let apiSecret = "API_SECRET_HERE"
        let url = URL(string: "https://api.sightengine.com/1.0/check.json")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"api_user\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(apiUser)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"api_secret\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(apiSecret)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"models\"\r\n\r\n".data(using: .utf8)!)
        body.append("nudity,wad,offensive,gore\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"media\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: body) { data, _, error in
            if let error = error {
                print("❌ Sightengine API error: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let data = data else {
                print("❌ Sightengine API returned no data")
                completion(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("✅ Sightengine API response: \(json)")
                    if let nudity = json["nudity"] as? [String: Any],
                       let nudityRaw = nudity["raw"] as? Double,
                       nudityRaw < 0.5,
                       let offensive = json["offensive"] as? [String: Any],
                       let offensiveProb = offensive["prob"] as? Double,
                       offensiveProb < 0.5,
                       let gore = json["gore"] as? [String: Any],
                       let goreProb = gore["prob"] as? Double,
                       goreProb < 0.5,
                       let weapon = json["weapon"] as? Double,
                       weapon < 0.5 {
                        
                        print("✅ Image passed all moderation checks")
                        completion(true) // Safe
                    } else {
                        print("❌ Image failed moderation")
                        completion(false) // Unsafe
                    }

                } else {
                    print("❌ Unexpected Sightengine API response")
                    completion(false)
                }
            } catch {
                print("❌ Sightengine JSON parse error: \(error)")
                completion(false)
            }
        }.resume()
    }

    func uploadPost() {
        guard let originalImage = selectedImage,
              let user = Auth.auth().currentUser else {
            print("❌ Upload aborted: No image or user not signed in")
            return
        }

        isUploading = true
        print("Starting post upload...")

        guard let compressedImageData = originalImage.jpegData(compressionQuality: 0.4) else {
            print("❌ Image compression failed")
            isUploading = false
            return
        }

        uploadImageToCloudinary(imageData: compressedImageData) { result in
            switch result {
            case .success(let imageUrl):
                print("✅ Image uploaded to Cloudinary: \(imageUrl)")
                let postDoc = Firestore.firestore().collection("posts").document()
                let postData: [String: Any] = [
                    "postId": postDoc.documentID,
                    "authorUID": user.uid,
                    "authorUsername": userName,
                    "authorProfileURL": userProfileURL,
                    "imageURL": imageUrl,
                    "caption": caption,
                    "timestamp": Timestamp(),
                    "likeCount": 0,
                    "likedBy": []
                ]
                postDoc.setData(postData) { error in
                    DispatchQueue.main.async {
                        isUploading = false
                        if let err = error {
                            print("❌ Firestore post save error: \(err.localizedDescription)")
                        } else {
                            print("✅ Post successfully saved to Firestore!")
                            dismiss()
                            onComplete()
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    isUploading = false
                    print("❌ Cloudinary upload failed: \(error.localizedDescription)")
                }
            }
        }
    }
    func checkTextWithPerspectiveAPI(_ text: String, completion: @escaping (Bool) -> Void) {
        guard !text.isEmpty else {
            print("⚠️ Empty caption, skipping moderation")
            completion(true)
            return
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "commentanalyzer.googleapis.com"
        components.path = "/v1alpha1/comments:analyze"
        components.queryItems = [
            URLQueryItem(name: "key", value: "API_KEY_HERE")
        ]
        
        guard let url = components.url else {
            print("❌ Invalid Perspective API URL")
            completion(true)
            return
        }
        
        let requestDict: [String: Any] = [
            "comment": ["text": text],
            "languages": ["en"],
            "requestedAttributes": ["TOXICITY": [:]]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestDict) else {
            print("❌ Failed to serialize JSON")
            completion(true)
            return
        }
        
        print("Sending moderation API request...")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Perspective API error: \(error.localizedDescription)")
                completion(true)
                return
            }
            guard let data = data else {
                print("❌ Perspective API returned no data")
                completion(true)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("✅ Perspective API response: \(json)")
                    if let attributeScores = json["attributeScores"] as? [String: Any],
                       let toxicity = attributeScores["TOXICITY"] as? [String: Any],
                       let summaryScore = toxicity["summaryScore"] as? [String: Any],
                       let value = summaryScore["value"] as? Double {
                        print("Toxicity Score: \(value)")
                        completion(value < 0.5)
                    } else {
                        print("⚠️ Unexpected Perspective API response format")
                        completion(true)
                    }
                }
            } catch {
                print("❌ Perspective API JSON parse error: \(error)")
                completion(true)
            }
        }.resume()
    }


    func uploadImageToCloudinary(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        print("Uploading image to Cloudinary...")
        let cloudName = "cloud_name"
        let uploadPreset = "imda_posts_uploads"
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: body) { data, _, error in
            if let error = error {
                print("❌ Cloudinary upload error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("❌ Cloudinary upload returned no data")
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("✅ Cloudinary response: \(json ?? [:])")
                if let secureUrl = json?["secure_url"] as? String {
                    completion(.success(secureUrl))
                } else {
                    print("❌ Cloudinary upload: No secure_url in response")
                    completion(.failure(NSError(domain: "Cloudinary", code: 0, userInfo: [NSLocalizedDescriptionKey: "No secure_url in response"])))
                }
            } catch {
                print("❌ Cloudinary JSON parse error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

}


