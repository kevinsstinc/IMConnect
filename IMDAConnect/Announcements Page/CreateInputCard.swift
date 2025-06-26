//
//  CreateInputCard.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 14/6/25.
//
import SwiftUI

struct CreateInputCard: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var multiline: Bool = false
    var editable: Bool = true

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
                        .background(Color.white.opacity(0.1).cornerRadius(12))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .disabled(!editable)
                } else {
                    TextField("", text: $text)
                        .padding(12)
                        .background(Color.white.opacity(0.1).cornerRadius(12))
                        .foregroundColor(.white)
                        .disabled(!editable)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.3), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
}
