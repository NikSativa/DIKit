import DIKit
import Foundation
import XCTest

final class AssemblyDependencyTests: XCTestCase {
    func test_container_assembles_each_dependency_before_the_assembly_that_lists_it() {
        let recorder = AssemblyRecorder()

        _ = Container(assemblies: [AppAssembly(recorder: recorder)])

        XCTAssertEqual(recorder.assembledNames, ["Core", "Feature", "App"])
    }

    func test_an_assembly_forwards_a_registration_of_its_dependency() {
        let container = Container(assemblies: [ServiceForwardingAssembly()])

        let service: any Servicing = container.resolve()

        XCTAssertTrue(service is Service)
    }
}

private final class AssemblyRecorder {
    private(set) var assembledNames: [String] = []

    func record(_ name: String) {
        assembledNames.append(name)
    }
}

private struct CoreAssembly: Assembly {
    let recorder: AssemblyRecorder

    func assemble(with registrator: Registrator) {
        recorder.record("Core")
    }
}

private struct FeatureAssembly: Assembly {
    let recorder: AssemblyRecorder

    var dependencies: [Assembly] {
        return [CoreAssembly(recorder: recorder)]
    }

    func assemble(with registrator: Registrator) {
        recorder.record("Feature")
    }
}

private struct AppAssembly: Assembly {
    let recorder: AssemblyRecorder

    var dependencies: [Assembly] {
        return [FeatureAssembly(recorder: recorder), CoreAssembly(recorder: recorder)]
    }

    func assemble(with registrator: Registrator) {
        recorder.record("App")
    }
}

private protocol Servicing: AnyObject {}

private final class Service: Servicing {}

private struct ServiceAssembly: Assembly {
    func assemble(with registrator: Registrator) {
        registrator.register(Service.self, options: .container) {
            return Service()
        }
    }
}

private struct ServiceForwardingAssembly: Assembly {
    var dependencies: [Assembly] {
        return [ServiceAssembly()]
    }

    func assemble(with registrator: Registrator) {
        registrator.registration(for: Service.self).implements((any Servicing).self)
    }
}
