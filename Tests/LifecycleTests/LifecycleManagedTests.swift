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

import Foundation
@testable import Lifecycle
import XCTest

final class LifecycleManagerTests: XCTestCase {
    func testBind() {
        let lifecylceManaged = TestLifecycleManaged()

        lifecylceManaged.scopeLifecycleManager.activate()

        XCTAssertEqual(lifecylceManaged.scopeLifecycleManager.owner as? TestLifecycleManaged, lifecylceManaged)
    }

    func testAddChild() {
        let parent = TestLifecycleManaged()
        let child = TestLifecycleManaged()

        XCTAssertFalse(child.isActive)

        XCTAssertTrue(parent.attachChild(child))

        XCTAssertEqual(parent.children as! [TestLifecycleManaged], [child])
        XCTAssertFalse(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 0)
        XCTAssertEqual(child.didBecomeActiveCount, 0)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        parent.scopeLifecycleManager.activate()

        XCTAssertEqual(parent.children as! [TestLifecycleManaged], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        XCTAssertFalse(parent.attachChild(child))

        XCTAssertEqual(parent.children as! [TestLifecycleManaged], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        parent.scopeLifecycleManager.deactivate()

        XCTAssertEqual(parent.children as! [TestLifecycleManaged], [child])
        XCTAssertFalse(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 1)

        parent.scopeLifecycleManager.activate()

        XCTAssertEqual(parent.children as! [TestLifecycleManaged], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 2)
        XCTAssertEqual(child.didBecomeInactiveCount, 1)

        parent.detachChild(child)

        XCTAssertEqual(parent.children as! [TestLifecycleManaged], [])
        XCTAssertTrue(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 2)
        XCTAssertEqual(child.didBecomeInactiveCount, 2)
    }

    func testAddParentAsChild_asserts() {
        let parent = TestLifecycleManaged()

        expectAssert {
            parent.attachChild(parent)
        }
    }

    func testAddChildAsChild_asserts() {
        let parent = TestLifecycleManaged()
        let child = TestLifecycleManaged()

        XCTAssertTrue(parent.attachChild(child))

        let parent2 = TestLifecycleManaged()

        expectAssert(passes: true) {
            expectAssert {
                parent2.attachChild(child)
            }
        }
    }

    func testDuplicateOwner_asserts() {
        let manager = ScopeLifecycleManager()
        let owner = TestLifecycleManaged(scopeLifecycleManager: manager)

        expectAssertionFailure {
            _ = TestLifecycleManaged(scopeLifecycleManager: manager)
        }

        XCTAssertNotNil(owner)
    }

    func testReleasedOwner() {
        let manager = ScopeLifecycleManager()

        autoreleasepool {
            let owner = TestLifecycleManaged(scopeLifecycleManager: manager)
            XCTAssertEqual(owner, manager.owner as! TestLifecycleManaged)
        }

        let owner = TestLifecycleManaged(scopeLifecycleManager: manager)

        XCTAssertEqual(owner, manager.owner as! TestLifecycleManaged)
    }

    func testBindAgain_asserts() {
        let parent = TestLifecycleManaged()
        expectAssertionFailure {
            parent.bind(to: parent.scopeLifecycleManager)
        }
    }

    func testWeakLifecycleManaged() {
        let weakLifecycleManaged = WeakLifecycleManaged(scopeLifecycleManager: ScopeLifecycleManager())

        XCTAssertNil(weakLifecycleManaged.scopeLifecycleManager)
        XCTAssertFalse(weakLifecycleManaged.attachChild(TestLifecycleManaged()))
        XCTAssertEqual(weakLifecycleManaged.lifecycleState, .deinitialized)
    }
}

protocol TestLifecycleManageable: LifecycleManageable {}

final class TestLifecycleManaged: LifecycleManaged, TestLifecycleManageable {

    var didLoadCount: Int = 0
    override func didLoad(_ lifecycleProvider: LifecycleProvider) {
        didLoadCount += 1
    }

    var didBecomeActiveCount: Int = 0
    override func didBecomeActive(_ lifecycleProvider: LifecycleProvider) {
        didBecomeActiveCount += 1
    }

    var didBecomeInactiveCount: Int = 0
    override func didBecomeInactive() {
        didBecomeInactiveCount += 1
    }
}
