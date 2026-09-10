import SwiftUI

public enum DesignSpace {
    public static let tiny: CGFloat = 4
    public static let compact: CGFloat = 8
    public static let small: CGFloat = 12
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
    public static let generous: CGFloat = 32
}
public enum DesignColor {
    public static let accent = Color.cyan
    public static let surface = Color.primary.opacity(0.04)
    public static let border = Color.primary.opacity(0.10)
    public static let positive = Color.green
    public static let warning = Color.orange
    public static let critical = Color.red
}
public enum DesignRadius {
    public static let card: CGFloat = 16
    public static let control: CGFloat = 10
}
