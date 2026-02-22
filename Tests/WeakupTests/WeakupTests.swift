import Testing
@testable import WeakupCore

@Suite("Weakup Tests")
struct WeakupTests {

    @Test("Placeholder test")
    func placeholder() {
        // Placeholder test - actual tests to be added
        #expect(true)
    }

    @Test("Logger can be used from detached task")
    func loggerCanBeUsedFromDetachedTask() async {
        let task = Task.detached {
            Logger.info("logger detached task test")
        }

        await task.value
    }
}
