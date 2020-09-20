//
//  RoomManager.swift
//  ScreenMirrorServer
//
//  Created by Liat Grinshpun on 08/16/2020.
//

import Foundation
import PerfectHTTP
import PerfectWebSockets

struct Client {
    let request: HTTPRequest
    let socket: WebSocket
}

class RoomManager {

    public static let instance = RoomManager()
    private init() {}

    let signalingHandler = SignalingHandler()
    var clients: [UUID: Client] = [:]

    func join(_ client: Client) -> UUID {
        let newId = UUID()
        self.clients[newId] = client
        print("new client joined: \(newId)")
        return newId
    }

    func otherClients(_ clientId: UUID) -> [Client] {
        var others = self.clients
        others.removeValue(forKey: clientId)
        print("other clients: \(others.keys)")
        return Array(others.values)
    }
}
