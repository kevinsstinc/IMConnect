//
//  TodoRow.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 26/6/25.
//
import SwiftUI
import FirebaseFirestore

struct TodoRow: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? .white : .white.opacity(0.7))
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())

            Text(item.text)
                .foregroundStyle(.white.opacity(0.88))
                .strikethrough(item.isDone, color: .white.opacity(0.7))
                .opacity(item.isDone ? 0.5 : 1)

            Spacer()

            if item.isDone {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .padding(.horizontal,8)
    }
}
