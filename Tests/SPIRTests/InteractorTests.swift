//
//  Copyright (c) 2021. Adam Share
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Combine
import Foundation
@testable import Lifecycle
@testable import SPIR
import XCTest

final class InteractorTests: XCTestCase {
    private let presenter = TestPresenter()
    private let scopeLifecycle = ScopeLifecycle()

    func testInteractor() {
        let interactor = Interactor(scopeLifecycle: scopeLifecycle)
        XCTAssertEqual(interactor.scopeLifecycle, scopeLifecycle)
    }

    func testRoutingInteractor() {
        let router = Router(scopeLifecycle: scopeLifecycle)
        let interactor = RoutingInteractor(router: router)
        XCTAssertEqual(interactor.scopeLifecycle, scopeLifecycle)
        XCTAssertEqual(interactor.router, router)
        XCTAssertTrue(scopeLifecycle.subscribers.contains(interactor))
    }

    func testPresentableInteractor() {
        let interactor = TestPresentableInteractor(scopeLifecycle: scopeLifecycle,
                                                   presenter: presenter)
        XCTAssertEqual(interactor.scopeLifecycle, scopeLifecycle)
        XCTAssertEqual(interactor.presenter, presenter)
        XCTAssertTrue(scopeLifecycle.subscribers.contains(interactor))
        XCTAssertTrue(presenter.viewLifecycle.subscribers.contains(interactor))
        XCTAssertTrue(presenter.viewLifecycle.scopeLifecycle === scopeLifecycle)
        XCTAssertTrue(scopeLifecycle.subscribers.contains(presenter))
    }

    func testPresentableRoutingInteractor() {
        let presenter = TestPresenter()
        let router = Router(scopeLifecycle: ScopeLifecycle())
        let interactor = TestPresentableRoutingInteractor(scopeLifecycle: scopeLifecycle,
                                                          presenter: presenter,
                                                          router: router)
        XCTAssertEqual(interactor.scopeLifecycle, router.scopeLifecycle)
        XCTAssertEqual(interactor.presenter, presenter)
        XCTAssertEqual(interactor.router, router)
        XCTAssertTrue(scopeLifecycle.subscribers.contains(interactor))
        XCTAssertTrue(presenter.viewLifecycle.subscribers.contains(interactor))
        XCTAssertTrue(presenter.viewLifecycle.scopeLifecycle === scopeLifecycle)
        XCTAssertTrue(scopeLifecycle.subscribers.contains(presenter))
    }
}

final class TestInteractor: Interactor {}
final class TestPresentableInteractor: PresentableInteractor<TestPresenter>, ViewLifecycleSubscriber {
    func viewDidLoad() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
}

final class TestPresentableRoutingInteractor: PresentableRoutingInteractor<TestPresenter, Router>, ViewLifecycleSubscriber {
    func viewDidLoad() {}
    func viewDidAppear() {}
    func viewDidDisappear() {}
}
