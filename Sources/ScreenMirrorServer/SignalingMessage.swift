import Foundation

enum MessageType: String, Decodable {
    case join
    case signal
}

struct TypedMessage: Decodable {
    let type: MessageType
    let clientId: Int?
    let data: String?
}