import Foundation
import Threading

final class CreationLock {
    private let lock = AnyLock.default
    private let valueLock = AnyLock.pthread(.normal)
    private let creationInProgress = AnyLock.pthread(.normal)
    private var creator: HeldLocks?

    func resolve<Value>(cached: () -> Value?, create: () -> Value, store: (Value) -> Value) -> Value {
        let heldLocks = HeldLocks.current
        let isMainThread = Thread.isMainThread
        lock.lock()

        while true {
            if let value = withValueLock(cached) {
                lock.unlock()
                return value
            }

            guard let creator, creator !== heldLocks, !isMainThread else {
                break
            }

            heldLocks.holding(lock) {
                heldLocks.released {
                    creationInProgress.lock()
                    creationInProgress.unlock()
                }
            }
        }

        let isCreator = creator == nil
        if isCreator {
            creator = heldLocks
            creationInProgress.lock()
        }

        let created = heldLocks.holding(lock) {
            return create()
        }
        let value = withValueLock {
            return store(created)
        }

        if isCreator {
            creator = nil
            creationInProgress.unlock()
        }
        lock.unlock()

        withExtendedLifetime(created) {}
        return value
    }

    func run<Value>(_ work: () -> Value) -> Value {
        return resolve(cached: {
            return Optional<Value>.none
        }, create: work, store: { value in
            return value
        })
    }

    func cachedValue<Value>(_ read: () -> Value?) -> Value? {
        return withValueLock(read)
    }

    private func withValueLock<T>(_ body: () -> T) -> T {
        valueLock.lock()
        defer {
            valueLock.unlock()
        }
        return body()
    }
}

extension CreationLock: @unchecked Sendable {}
