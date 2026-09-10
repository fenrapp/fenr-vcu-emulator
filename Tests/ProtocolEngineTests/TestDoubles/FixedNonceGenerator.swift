import Foundation
import ProtocolEngine

struct FixedNonceGenerator: NonceGenerating {
    func generate() -> Data { Data(0..<32) }
}
