struct ConfigurationViewState {
    let chargingPower: String
    let chargeTarget: String
    let lockStatus: String
    let maps: [MapRow]

    struct MapRow: Identifiable {
        let id: Int
        let title: String
        let torque: String
        let regeneration: String
        let powerTraction: String
        let brakingTraction: String
        let powerCurve: String
        let regenerationCurve: String
    }
}
