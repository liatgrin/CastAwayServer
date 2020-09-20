import Foundation
import PerfectWebSockets
import PerfectHTTP

class SignalingHandler: WebSocketSessionHandler {

    let socketProtocol: String? = nil
    
    func handleSession(request req: HTTPRequest, socket: WebSocket) {

        socket.readBytesMessage { bytes, op, fin in 
            guard let b = bytes,
                let message = WebSocketMessage.from(data: Data(b))
            else {
                print(String(bytes: bytes ?? [UInt8](), encoding: .utf8) ?? "")
                return 
            }

            switch message.type {
            case .join:
                print("new client joined")
                let client = Client(request: req, socket: socket)
                let clientId = RoomManager.instance.join(client)
                let response = WebSocketMessage(type: .joined, clientId: clientId, body: nil)
                self.send(message: response, to: client)
            case .signal:
                guard let clientId = message.clientId else { break }
                print("got signal from client \(clientId): \(message.body ?? "")")
                let otherClients = RoomManager.instance.otherClients(clientId)
                otherClients.forEach { client in
                    self.send(message: message, to: client)
                }
            default:
                break
            }

            self.handleSession(request: req, socket: socket)
        }
    }

    private func send(message: WebSocketMessage, to client: Client) {
        print("sending message \(message.body ?? "")")
        guard let data = message.toData() else { return }
        client.socket.sendBinaryMessage(bytes: Array(data), final: true) {
            self.handleSession(request: client.request, socket: client.socket)
        }
    }
}
