import Foundation

public enum StarkFirmwareVersionParser {
    public static func parseVCUBottom(from data: Data) -> StarkFirmwareVersion? {
        let bytes = Array(data)
        guard bytes.count >= 12, bytes[11] == 0,
              (1 ... 9).contains(bytes[10]), bytes[9] <= 99, bytes[8] <= 99 else { return nil }
        return StarkFirmwareVersion(major: Int(bytes[10]), minor: Int(bytes[9]), patch: Int(bytes[8]))
    }

    public static func parseVCUPic(from data: Data) -> StarkFirmwareVersion? {
        if let asciiVersion = parseASCII(from: data) {
            return asciiVersion
        }
        if let vcuPICVersion = parseVersionBlocks(from: data).first {
            return vcuPICVersion
        }
        return parseBinaryTriplet(from: data)
    }

    public static func parseVersionBlockDescriptions(from data: Data) -> [String] {
        parseVersionBlocks(from: data).map(\.description)
    }

    private static func parseASCII(from data: Data) -> StarkFirmwareVersion? {
        let asciiBytes = data.filter { byte in
            byte == 0x2E || byte == 0x2D || byte == 0x5F || (0x20 ... 0x7E).contains(byte)
        }
        let ascii = String(bytes: asciiBytes, encoding: .utf8) ?? ""
        guard let match = ascii.range(
            of: #"(\d+)\.(\d+)\.(\d+)"#,
            options: .regularExpression
        ) else {
            return nil
        }
        return StarkFirmwareVersion(String(ascii[match]))
    }

    private static func parseBinaryTriplet(from data: Data) -> StarkFirmwareVersion? {
        guard data.count >= 3 else { return nil }
        let bytes = Array(data)
        for index in 0 ... (bytes.count - 3) {
            let major = Int(bytes[index])
            let minor = Int(bytes[index + 1])
            let patch = Int(bytes[index + 2])
            guard (1 ... 9).contains(major),
                  (0 ... 99).contains(minor),
                  (0 ... 99).contains(patch)
            else {
                continue
            }
            return StarkFirmwareVersion(major: major, minor: minor, patch: patch)
        }
        return nil
    }

    private static func parseVersionBlocks(from data: Data) -> [StarkFirmwareVersion] {
        guard data.count >= 4 else { return [] }
        let bytes = Array(data)
        return stride(from: 0, through: bytes.count - 4, by: 4).compactMap { index in
            let patch = Int(bytes[index])
            let minor = Int(bytes[index + 1])
            let major = Int(bytes[index + 2])
            let reserved = bytes[index + 3]
            guard reserved == 0x00,
                  (1 ... 9).contains(major),
                  (0 ... 99).contains(minor),
                  (0 ... 99).contains(patch)
            else {
                return nil
            }
            return StarkFirmwareVersion(major: major, minor: minor, patch: patch)
        }
    }
}
