public struct ConfigurationEditorState {
    public var selected: Int
    public var choices: [ConfigurationChoice]
    public var fields: [ConfigurationField]
    public var dirty = false
    public var conflict = false
    public var message: String?
    public var points: [CurvePoint] = []
}
