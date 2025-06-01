//
//  EditProfileSheet.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 30/5/25.
//


import SwiftUI

struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var role: String
    @Binding var school: String
    @Binding var about: String
    @Environment(\.dismiss) var dismiss
    @State private var pulse = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 74/255, green: 31/255, blue: 91/255),
                        Color(red: 100/255, green: 42/255, blue: 122/255)
                    ]),
                    startPoint: pulse ? .topLeading : .bottomTrailing,
                    endPoint: pulse ? .bottomTrailing : .topLeading
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: pulse)

                ScrollView {
                    VStack(spacing: 25) {
                        ProfileInputCard(title: "Name", text: $name)
                        ProfileInputCard(title: "Role", text: $role)
                        ProfileInputCard(title: "School", text: $school)
                        ProfileInputCard(title: "About", text: $about, placeholder: "Write about yourself...", multiline: true)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                    .font(.headline)
                }
            }
            .onAppear {
                withAnimation {
                    pulse.toggle()
                }
            }
        }
    }
}

struct ProfileInputCard: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var multiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline.weight(.medium))

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.3))
                        .padding(14)
                }

                if multiline {
                    TextEditor(text: $text)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(glassyBackground)
                        .cornerRadius(16)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                } else {
                    TextField(title, text: $text)
                        .padding(12)
                        .background(glassyBackground)
                        .cornerRadius(16)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.12))
                .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 6)
                .shadow(color: Color.pink.opacity(0.3), radius: 8, x: 3, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var glassyBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.1))
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}


