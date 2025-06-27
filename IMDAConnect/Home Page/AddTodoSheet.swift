//
//  AddTodoSheet.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 26/6/25.
//
import SwiftUI
import FirebaseFirestore

struct AddTodoSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var newTodoText = ""
    var onAdd: (String) -> Void

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
            VStack(spacing: 28) {
                Text("Add New To-Do")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 30)

                TextField("Enter your task...", text: $newTodoText)
                    .padding()
                    .background(Color.white.opacity(0.12).cornerRadius(12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)

                Button {
                    let trimmed = newTodoText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        onAdd(trimmed)
                        dismiss()
                    }
                } label: {
                    Text("Add Task")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.25))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }

                Spacer()
            }
        }
    }
}
