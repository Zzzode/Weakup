import XCTest
@testable import WeakupCore

final class WeakupTests: XCTestCase {
    func testPlaceholder() {
        // Placeholder test - actual tests to be added
        XCTAssertTrue(true)
    }

    func testLogger_canBeUsedFromDetachedTask() async {
        let task = Task.detached {
            Logger.info("logger detached task test")
        }

        await task.value
    }
}
