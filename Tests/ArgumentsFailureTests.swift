#if compiler(>=6.2) && os(macOS)
import DIKit
import Foundation
import Testing

struct ArgumentsFailureTests {
    @Test
    func resolvingAnArgumentOfAnotherTypeStopsWithTheTypeAndTheIndex() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let arguments = Arguments(1)
            _ = arguments.resolve(String.self, at: 0)
        }

        let output = result.map {
            return String(decoding: $0.standardErrorContent, as: UTF8.self)
        }
        #expect(output?.contains("Arguments has no <String> at index 0") == true)
    }

    @Test
    func readingAMissingIndexStopsWithTheTypeAndTheIndex() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let arguments = Arguments(1)
            let value: Int = arguments[1]
            _ = value
        }

        let output = result.map {
            return String(decoding: $0.standardErrorContent, as: UTF8.self)
        }
        #expect(output?.contains("Arguments has no <Int> at index 1") == true)
    }

    @Test
    func readingTheFirstArgumentOfAMissingTypeStopsWithTheType() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let arguments = Arguments(1)
            _ = arguments.first(String.self)
        }

        let output = result.map {
            return String(decoding: $0.standardErrorContent, as: UTF8.self)
        }
        #expect(output?.contains("Arguments has no <String>") == true)
    }
}
#endif
