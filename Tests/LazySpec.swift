import Foundation
import Nimble
import NSpry
import NSpry_Nimble
import Quick

@testable import NInject
@testable import NInjectTestHelpers

final class LazySpec: QuickSpec {
    private struct Instance {}

    override func spec() {
        describe("Lazy") {
            var subject: Lazy<Instance>!
            var container: Container!
            var resolvingCounter: Int!

            beforeEach {
                resolvingCounter = 0
                container = .init(assemblies: [], shared: false)
            }

            context("when registered weak") {
                beforeEach {
                    container.register(Instance.self, options: .weak) {
                        resolvingCounter += 1
                        return Instance()
                    }
                    subject = container.resolveWrapped()
                }

                it("should not be instantiated") {
                    expect(resolvingCounter) == 0
                }

                it("should create Lazy instance") {
                    expect(subject).toNot(beNil())
                }

                context("when instanciate") {
                    var actual: Instance!

                    beforeEach {
                        actual = subject.instance
                    }

                    it("should be instantiated") {
                        expect(resolvingCounter) == 1
                    }

                    it("should create Lazy instance") {
                        expect(actual).toNot(beNil())
                        expect(subject).toNot(beNil())
                    }

                    context("when instanciate") {
                        var actual: Instance!

                        beforeEach {
                            actual = subject.instance
                        }

                        it("should not be instantiated again") {
                            expect(resolvingCounter) == 1
                        }

                        it("should create Lazy instance") {
                            expect(actual).toNot(beNil())
                            expect(subject).toNot(beNil())
                        }
                    }
                }
            }

            context("when registered transient") {
                beforeEach {
                    container.register(Instance.self, options: .transient) {
                        resolvingCounter += 1
                        return Instance()
                    }
                    subject = container.resolveWrapped()
                }

                it("should not be instantiated") {
                    expect(resolvingCounter) == 0
                }

                it("should create Lazy instance") {
                    expect(subject).toNot(beNil())
                }

                context("when instanciate") {
                    var actual: Instance!

                    beforeEach {
                        actual = subject.instance
                    }

                    it("should be instantiated") {
                        expect(resolvingCounter) == 1
                    }

                    it("should create Lazy instance") {
                        expect(actual).toNot(beNil())
                        expect(subject).toNot(beNil())
                    }

                    context("when instanciate") {
                        var actual: Instance!

                        beforeEach {
                            actual = subject.instance
                        }

                        it("should not be instantiated again") {
                            expect(resolvingCounter) == 1
                        }

                        it("should create Lazy instance") {
                            expect(actual).toNot(beNil())
                            expect(subject).toNot(beNil())
                        }
                    }
                }
            }
        }
    }
}
