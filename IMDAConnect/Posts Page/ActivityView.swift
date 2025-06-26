//
//  ActivityView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 24/6/25.
//
import SwiftUI
import UIKit

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
