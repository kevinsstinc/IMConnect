//
//  NetworkMonitor.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 10/7/25.
//
import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = true
    private var monitor: NWPathMonitor
    private let queue = DispatchQueue.global()
    
    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
