import Testing
import VehicleSimulation
@testable import ConfigurationFeature

@Test func curveEditorPreservesAllSamplesAndRejectsInvalidInput() throws {
    let mapper = ConfigurationEditorMapper()
    let original = VehicleConfiguration.defaults
    var fields = mapper.fields(original, block: .curve(3))
    #expect(fields.count == 30)
    fields[0].text = "63.7"
    fields[29].text = "0.1"
    #expect(mapper.validated(fields).allSatisfy { $0.error == nil })
    let candidate = try mapper.applying(fields, block: .curve(3), to: original)
    #expect(candidate.curves[3].power[0] == 637)
    #expect(candidate.curves[3].regeneration[14] == 1)
    #expect(candidate.curves[2] == original.curves[2])
    fields[0].text = "nan"
    #expect(mapper.validated(fields)[0].error != nil)
    fields[0].text = "100.01"
    #expect(mapper.validated(fields)[0].error != nil)
}
@Test func signedTractionAndChargeTargetHaveDistinctPrecision() throws {
    let mapper = ConfigurationEditorMapper()
    var fields = mapper.fields(.defaults, block: .traction(0))
    fields[0].text = "-12.3"
    #expect(mapper.validated(fields)[0].error == nil)
    #expect(try mapper.applying(fields, block: .traction(0), to: .defaults).traction[0].power == -123)
    fields = mapper.fields(.defaults, block: .charger)
    fields[1].text = "80.5"
    #expect(mapper.validated(fields)[1].error != nil)
}

@Test func incompleteAndNonfiniteDraftsAreRejectedWithoutTrapping() {
    let mapper = ConfigurationEditorMapper()
    #expect(throws: (any Error).self) { try mapper.applying([], block: .charger, to: .defaults) }
    var fields = mapper.fields(.defaults, block: .charger)
    fields[0].text = "inf"
    #expect(throws: (any Error).self) { try mapper.applying(fields, block: .charger, to: .defaults) }
    #expect(throws: (any Error).self) { try mapper.applying(fields, block: .map(99), to: .defaults) }
}
