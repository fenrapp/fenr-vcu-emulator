public struct StarkChargerConfiguration: Equatable, Sendable {
    public let save: UInt8
    public let chargeCurrentDeciAmperes: Int
    public let chargePowerWatts: Int
    public let maximumStateOfChargeDeciPercent: Int
    public let minimumCurrentDeciAmperes: Int
    public let startTimeRaw: Int
    public let rampTimeRaw: Int
    public let standardChargerMaximumPowerWatts: Int
    public let backpackChargerMaximumPowerWatts: Int

    public init(
        save: UInt8 = 1,
        chargeCurrentDeciAmperes: Int,
        chargePowerWatts: Int,
        maximumStateOfChargeDeciPercent: Int,
        minimumCurrentDeciAmperes: Int = 0,
        startTimeRaw: Int = 0,
        rampTimeRaw: Int = 0,
        standardChargerMaximumPowerWatts: Int,
        backpackChargerMaximumPowerWatts: Int
    ) {
        self.save = save
        self.chargeCurrentDeciAmperes = chargeCurrentDeciAmperes
        self.chargePowerWatts = chargePowerWatts
        self.maximumStateOfChargeDeciPercent = maximumStateOfChargeDeciPercent
        self.minimumCurrentDeciAmperes = minimumCurrentDeciAmperes
        self.startTimeRaw = startTimeRaw
        self.rampTimeRaw = rampTimeRaw
        self.standardChargerMaximumPowerWatts = standardChargerMaximumPowerWatts
        self.backpackChargerMaximumPowerWatts = backpackChargerMaximumPowerWatts
    }

    public func settingChargePower(_ watts: Int, chargerType: StarkChargerType) -> Self {
        let nextCurrentDeciAmperes =
            chargeCurrentDeciAmperes == StarkChargePowerControlLimits.twoAmpereRegressionCurrentDeciAmperes
            ? chargerType.chargeCurrentLimitDeciAmperes
            : chargeCurrentDeciAmperes
        let nextMaximumPowerWatts: (standard: Int, backpack: Int)
        switch chargerType {
        case .standard, .backpack, .unknown:
            let sharedMaximumPowerWatts = min(
                max(standardChargerMaximumPowerWatts, watts),
                chargerType.maximumChargePowerWatts
            )
            nextMaximumPowerWatts = (sharedMaximumPowerWatts, sharedMaximumPowerWatts)
        case .fast:
            nextMaximumPowerWatts = (
                standardChargerMaximumPowerWatts,
                backpackChargerMaximumPowerWatts
            )
        }
        return Self(
            save: save,
            chargeCurrentDeciAmperes: nextCurrentDeciAmperes,
            chargePowerWatts: watts,
            maximumStateOfChargeDeciPercent: maximumStateOfChargeDeciPercent,
            minimumCurrentDeciAmperes: minimumCurrentDeciAmperes,
            startTimeRaw: startTimeRaw,
            rampTimeRaw: rampTimeRaw,
            standardChargerMaximumPowerWatts: nextMaximumPowerWatts.standard,
            backpackChargerMaximumPowerWatts: nextMaximumPowerWatts.backpack
        )
    }

    public func settingMaximumStateOfCharge(percent: Int) -> Self {
        return Self(
            save: save,
            chargeCurrentDeciAmperes: chargeCurrentDeciAmperes,
            chargePowerWatts: chargePowerWatts,
            maximumStateOfChargeDeciPercent: percent * 10,
            minimumCurrentDeciAmperes: minimumCurrentDeciAmperes,
            startTimeRaw: startTimeRaw,
            rampTimeRaw: rampTimeRaw,
            standardChargerMaximumPowerWatts: standardChargerMaximumPowerWatts,
            backpackChargerMaximumPowerWatts: backpackChargerMaximumPowerWatts
        )
    }
}
