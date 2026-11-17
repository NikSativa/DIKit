import Foundation
import Threading

final class HeldLocks {
    private static let threadDictionaryKey = "DIKit.HeldLocks.\(ObjectIdentifier(HeldLocks.self))"

    private var locks: [AnyLock] = []

    static var current: HeldLocks {
        let threadDictionary = Thread.current.threadDictionary
        if let heldLocks = threadDictionary[threadDictionaryKey] as? HeldLocks {
            return heldLocks
        }

        let heldLocks = HeldLocks()
        threadDictionary[threadDictionaryKey] = heldLocks
        return heldLocks
    }

    func holding<T>(_ lock: AnyLock, during work: () -> T) -> T {
        locks.append(lock)
        defer {
            locks.removeLast()
        }
        return work()
    }

    func released<T>(during wait: () -> T) -> T {
        let releasedLocks = locks
        locks = []
        for lock in releasedLocks.reversed() {
            lock.unlock()
        }
        defer {
            for lock in releasedLocks {
                lock.lock()
            }
            locks = releasedLocks
        }
        return wait()
    }
}
