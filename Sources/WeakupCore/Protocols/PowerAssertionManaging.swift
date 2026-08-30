import Foundation
import IOKit.pwr_mgt

enum PowerAssertionKind: String, Hashable, Sendable {
    case systemSleep
    case displaySleep
}

@MainActor
protocol PowerAssertionManaging: AnyObject {
    func createAssertion(_ kind: PowerAssertionKind, reason: String) throws -> IOPMAssertionID
    @discardableResult
    func releaseAssertion(_ id: IOPMAssertionID) -> IOReturn
}

enum PowerAssertionError: LocalizedError {
    case creationFailed(kind: PowerAssertionKind, code: IOReturn)
    case releaseFailed(kind: PowerAssertionKind, code: IOReturn)

    var errorDescription: String? {
        switch self {
        case let .creationFailed(kind, code):
            "Failed to create \(kind.rawValue) assertion (IOKit error \(code))"
        case let .releaseFailed(kind, code):
            "Failed to release \(kind.rawValue) assertion (IOKit error \(code))"
        }
    }
}

final class IOKitPowerAssertionManager: PowerAssertionManaging {
    func createAssertion(_ kind: PowerAssertionKind, reason: String) throws -> IOPMAssertionID {
        let assertionType: CFString = switch kind {
        case .systemSleep:
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString
        case .displaySleep:
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString
        }

        var assertionID: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            assertionType,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &assertionID
        )

        guard result == kIOReturnSuccess else {
            throw PowerAssertionError.creationFailed(kind: kind, code: result)
        }
        return assertionID
    }

    func releaseAssertion(_ id: IOPMAssertionID) -> IOReturn {
        IOPMAssertionRelease(id)
    }
}
