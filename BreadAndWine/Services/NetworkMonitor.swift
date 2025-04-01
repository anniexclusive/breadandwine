//
//  NetworkMonitor 2.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//
import SwiftUI
import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private(set) var isConnected = false
    private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            
            if path.usesInterfaceType(.wifi) {
                self?.connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self?.connectionType = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                self?.connectionType = .ethernet
            } else {
                self?.connectionType = .unknown
            }
            
            print("🌐 Network connection status: \(path.status == .satisfied ? "Connected" : "Disconnected") - Type: \(self?.connectionType ?? .unknown)")
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
