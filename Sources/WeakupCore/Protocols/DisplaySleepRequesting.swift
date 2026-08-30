import Foundation

@MainActor
protocol DisplaySleepRequesting: AnyObject {
    func requestDisplaySleep() async throws
}

enum DisplaySleepRequestError: LocalizedError {
    case commandFailed(status: Int32)
    case rollbackIncomplete

    var errorDescription: String? {
        switch self {
        case let .commandFailed(status):
            "pmset displaysleepnow failed with exit status \(status)"
        case .rollbackIncomplete:
            "Display sleep failed and the previous power state could not be fully restored"
        }
    }
}

final class PMSetDisplaySleepRequester: DisplaySleepRequesting {
    func requestDisplaySleep() async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["displaysleepnow"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            process.terminationHandler = { completedProcess in
                guard
                    completedProcess.terminationReason == .exit,
                    completedProcess.terminationStatus == 0 else
                {
                    continuation.resume(throwing: DisplaySleepRequestError.commandFailed(
                        status: completedProcess.terminationStatus
                    ))
                    return
                }
                continuation.resume()
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
