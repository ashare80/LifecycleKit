//
//  Copyright (c) 2020. Adam Share
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
@testable import SPIR
import XCTest

final class InteractorTests: XCTestCase {
    private let viewLifecycleManager = ViewLifecycleManager()
    private let scopeLifecycleManager = ScopeLifecycleManager()
    
    func testInteractor() {
        let interactor = Interactor(scopeLifecycleManager: scopeLifecycleManager)
        XCTAssertEqual(interactor.scopeLifecycleManager, scopeLifecycleManager)
    }
    
    func testRoutingInteractor() {
        let router = Router()
        let interactor = RoutingInteractor(scopeLifecycleManager: scopeLifecycleManager,
                                           router: router)
        XCTAssertEqual(interactor.scopeLifecycleManager, scopeLifecycleManager)
        XCTAssertEqual(interactor.router, router)
        XCTAssertTrue(scopeLifecycleManager.binded.contains(interactor))
    }
    
    func testPresentableInteractor() {
        let presenter = TestPresenter()
        let interactor = PresentableInteractor(scopeLifecycleManager: scopeLifecycleManager,
                                               presenter: presenter,
                                               viewLifecycleManager: viewLifecycleManager)
        XCTAssertEqual(interactor.scopeLifecycleManager, scopeLifecycleManager)
        XCTAssertEqual(interactor.presenter, presenter)
        XCTAssertTrue(scopeLifecycleManager.binded.contains(interactor))
        XCTAssertTrue(viewLifecycleManager.binded.contains(interactor))
    }
    
    func testPresentableRoutingInteractor() {
        let presenter = TestPresenter()
        let router = Router()
        let interactor = PresentableRoutingInteractor(scopeLifecycleManager: scopeLifecycleManager,
                                                      presenter: presenter,
                                                      router: router,
                                                      viewLifecycleManager: viewLifecycleManager)
        XCTAssertEqual(interactor.scopeLifecycleManager, scopeLifecycleManager)
        XCTAssertEqual(interactor.presenter, presenter)
        XCTAssertEqual(interactor.router, router)
        XCTAssertTrue(scopeLifecycleManager.binded.contains(interactor))
        XCTAssertTrue(viewLifecycleManager.binded.contains(interactor))
    }
}
