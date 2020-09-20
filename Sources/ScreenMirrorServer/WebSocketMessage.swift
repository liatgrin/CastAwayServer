//
//  WebSocketMessage.swift
//  ScreenMirrorServer
//
//  Created by Liat Grinshpun on 09/05/2020.
//

import Foundation

enum MessageType: String, Codable {
    case join, joined, signal
}

struct WebSocketMessage: Codable {
    let type: MessageType
    let clientId: UUID?
    let body: String?

    static func from(data: Data) -> WebSocketMessage? {
        return try? JSONDecoder().decode(WebSocketMessage.self, from: data)
    }

    func toData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

