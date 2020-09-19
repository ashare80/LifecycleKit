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
@testable import Lifecycle
@testable import SPIR
import XCTest

final class RouterTests: XCTestCase {
    func testRouterBinding() {
        let scopeLifecycleManager = ScopeLifecycleManager()
        let router = Router(scopeLifecycleManager: scopeLifecycleManager)
        XCTAssertTrue(scopeLifecycleManager.binded.contains(router))
    }
    
    func testPresentableRouterBinding() {
        let scopeLifecycleManager = ScopeLifecycleManager()
        let viewLifecycleManager = ViewLifecycleManager()
        let router = PresentableRouter(scopeLifecycleManager: scopeLifecycleManager,
                                       presenter: TestPresenter(),
                                       viewLifecycleManager: viewLifecycleManager)
        XCTAssertTrue(scopeLifecycleManager.binded.contains(router))
        XCTAssertTrue(viewLifecycleManager.binded.contains(router))
    }
}
