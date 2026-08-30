import IOKit.pwr_mgt
@testable import WeakupCore

@MainActor
final class MockPowerAssertionManager: PowerAssertionManaging {
    var creationFailures: Set<PowerAssertionKind> = []
    var releaseFailuresRemaining = 0
    private(set) var createdKinds: [PowerAssertionKind] = []
    private(set) var releasedIDs: [IOPMAssertionID] = []
    private var nextID: IOPMAssertionID = 1

    func createAssertion(
        _ kind: PowerAssertionKind,
        reason: String
    ) throws -> IOPMAssertionID {
        if creationFailures.contains(kind) {
            throw PowerAssertionError.creationFailed(kind: kind, code: kIOReturnError)
        }

        createdKinds.append(kind)
        defer { nextID += 1 }
        return nextID
    }

    func releaseAssertion(_ id: IOPMAssertionID) -> IOReturn {
        if releaseFailuresRemaining > 0 {
            releaseFailuresRemaining -= 1
            return kIOReturnError
        }
        releasedIDs.append(id)
        return kIOReturnSuccess
    }
}

@MainActor
final class MockDisplaySleepRequester: DisplaySleepRequesting {
    var error: Error?
    var shouldSuspend = false
    private(set) var requestCount = 0
    private var continuation: CheckedContinuation<Void, Never>?

    func requestDisplaySleep() async throws {
        requestCount += 1
        if shouldSuspend {
            await withCheckedContinuation { continuation in
                self.continuation = continuation
            }
        }
        if let error {
            throw error
        }
    }

    func completeRequest() {
        continuation?.resume()
        continuation = nil
    }
}
