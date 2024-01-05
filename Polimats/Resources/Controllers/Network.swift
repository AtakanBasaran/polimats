//
//  Network.swift
//  Polimats
//
//  Created by Atakan Başaran on 2.01.2024.
//

import Foundation
import Network


class Network {
    
    let monitor = NWPathMonitor()
    
    func checkConnection(completion: @escaping (Bool) -> Void) {
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            let isConnected = (path.status == .satisfied)
            completion(isConnected)
        }
    }
    
}
