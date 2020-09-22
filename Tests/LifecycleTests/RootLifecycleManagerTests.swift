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

@testable import Lifecycle
import SwiftUI
import XCTest

final class RootLifecycleManagerTests: XCTestCase {

    let delegate = Delegate()

    func testDelegates() {
        XCTAssertEqual(delegate.rootLifecycleManageable.scopeLifecycleManager.lifecycleState, .initialized)

        delegate.activateRoot()

        XCTAssertEqual(delegate.rootLifecycleManageable.scopeLifecycleManager.lifecycleState, .active)

        delegate.deactivateRoot()

        XCTAssertEqual(delegate.rootLifecycleManageable.scopeLifecycleManager.lifecycleState, .inactive)
    }
}

#if os(macOS)

    final class Delegate: NSObject, NSApplicationDelegate, RootLifecycleManager {
        var rootLifecycleManageable: LifecycleManageable = TestLifecycleManaged()
    }

#else

    final class Delegate: NSObject, UISceneDelegate, RootLifecycleManager {
        var rootLifecycleManageable: LifecycleManageable = TestLifecycleManaged()
    }

#endif
