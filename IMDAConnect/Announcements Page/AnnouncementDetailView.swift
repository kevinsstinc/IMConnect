//
//  AnnouncementDetailView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 13/6/25.
//
import SwiftUI

struct AnnouncementDetailView: View {
    let announcement: Announcement
    @State private var pulse = false

    var body: some View {
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

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(announcement.title)
                            .font(.system(size: 39, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.leading, 4)
                        Text(announcement.author)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.85))
                            .padding(4)
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .foregroundColor(.white.opacity(0.8))
                            Text(announcement.date, style: .date)
                                .foregroundColor(.white.opacity(0.8))
                        }

                    }
                    .padding()
                    .padding(.horizontal)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity, maxHeight: 2)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Announcement Details")
                            .font(.headline)
                            .padding(.bottom, 4)
                            .foregroundColor(.white.opacity(0.9))
                        Text(announcement.content)
                            .foregroundColor(.white.opacity(0.85))
                            .font(.body)
                    }
                    .padding()
                    .padding(.horizontal)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity, maxHeight: 2)
                    if let urlStr = announcement.pdfURL, let documentURL = URL(string: urlStr) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Attached Document")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))

                            Link(destination: documentURL) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.white)
                                        .imageScale(.large)
                                    Text("Open Document")
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding()
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            pulse = true
        }
    }
}
