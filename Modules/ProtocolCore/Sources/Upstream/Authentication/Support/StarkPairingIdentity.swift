import Foundation

public enum StarkPairingIdentity {
    public static func normalizedVIN(_ vin: String) -> String {
        String(vin.uppercased().filter { $0.isLetter || $0.isNumber })
    }

    public static func isValidVIN(_ vin: String) -> Bool {
        let normalizedVIN = normalizedVIN(vin)
        guard normalizedVIN.count == 17 else { return false }
        return normalizedVIN.allSatisfy { character in
            character.isNumber || (character.isLetter && !"IOQ".contains(character))
        }
    }

    public static func matches(_ candidate: String?, targetVIN: String) -> Bool {
        guard let candidate else { return false }
        let normalizedCandidate = normalizedVIN(candidate)
        let normalizedTarget = normalizedVIN(targetVIN)
        guard !normalizedCandidate.isEmpty, !normalizedTarget.isEmpty else { return false }
        if normalizedCandidate == normalizedTarget { return true }
        guard normalizedCandidate.count >= 8, normalizedTarget.count >= 8 else { return false }
        return normalizedCandidate.hasSuffix(normalizedTarget)
            || normalizedTarget.hasSuffix(normalizedCandidate)
    }

    public static func normalizedDate(_ pairingDate: String) -> String {
        let digits = pairingDate.filter(\.isNumber)
        guard digits.count >= StarkPinConstants.pairingDateDigits else {
            return StarkPinConstants.fallbackPairingDate
        }
        return String(digits.prefix(StarkPinConstants.pairingDateDigits))
    }
}
