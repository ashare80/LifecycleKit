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
        let lifecylceManaged = TestLifecycleManageableMock()

        lifecylceManaged.scopeLifecycleManager.activate()

        XCTAssertEqual(lifecylceManaged.scopeLifecycleManager.owner as? TestLifecycleManageableMock, lifecylceManaged)
    }

    func testAddChild() {
        let parent = TestLifecycleManageableMock()
        let child = TestLifecycleManageableMock()

        XCTAssertFalse(child.isActive)

        parent.attachChild(child)

        XCTAssertEqual(parent.children as! [TestLifecycleManageableMock], [child])
        XCTAssertFalse(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 0)
        XCTAssertEqual(child.didBecomeActiveCount, 0)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        parent.scopeLifecycleManager.activate()

        XCTAssertEqual(parent.children as! [TestLifecycleManageableMock], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        parent.attachChild(child)

        XCTAssertEqual(parent.children as! [TestLifecycleManageableMock], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 0)

        parent.scopeLifecycleManager.deactivate()

        XCTAssertEqual(parent.children as! [TestLifecycleManageableMock], [child])
        XCTAssertFalse(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 1)
        XCTAssertEqual(child.didBecomeInactiveCount, 1)

        parent.scopeLifecycleManager.activate()

        XCTAssertEqual(parent.children as! [TestLifecycleManageableMock], [child])
        XCTAssertTrue(parent.isActive)
        XCTAssertTrue(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 2)
        XCTAssertEqual(child.didBecomeInactiveCount, 1)

        parent.detachChild(child)

        XCTAssertEqual(parent.children as! [TestLifecycleManageableMock], [])
        XCTAssertTrue(parent.isActive)
        XCTAssertFalse(child.isActive)
        XCTAssertEqual(child.didLoadCount, 1)
        XCTAssertEqual(child.didBecomeActiveCount, 2)
        XCTAssertEqual(child.didBecomeInactiveCount, 2)
    }

    func testAddParentAsChild_asserts() {
        let parent = TestLifecycleManageableMock()

        expectAssert {
            parent.attachChild(parent)
        }
    }

    func testAddChildAsChild_asserts() {
        let parent = TestLifecycleManageableMock()
        let child = TestLifecycleManageableMock()

        parent.attachChild(child)

        let parent2 = TestLifecycleManageableMock()

        expectAssert {
            parent2.attachChild(parent)
        }
    }

    func testDuplicateOwner_asserts() {
        let manager = ScopeLifecycleManager()
        let owner = TestLifecycleManageableMock(scopeLifecycleManager: manager)

        expectAssertionFailure {
            _ = TestLifecycleManageableMock(scopeLifecycleManager: manager)
        }

        XCTAssertNotNil(owner)
    }

    func testReleasedOwner() {
        let manager = ScopeLifecycleManager()

        autoreleasepool {
            let owner = TestLifecycleManageableMock(scopeLifecycleManager: manager)
            XCTAssertEqual(owner, manager.owner as! TestLifecycleManageableMock)
        }

        let owner = TestLifecycleManageableMock(scopeLifecycleManager: manager)

        XCTAssertEqual(owner, manager.owner as! TestLifecycleManageableMock)
    }

    func testBindAgain_asserts() {
        let parent = TestLifecycleManageableMock()
        expectAssertionFailure {
            parent.bind(to: parent.scopeLifecycleManager)
        }
    }
}

protocol TestLifecycleManageable: LifecycleManageable {}

final class TestLifecycleManageableMock: LifecycleManaged, TestLifecycleManageable {

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
