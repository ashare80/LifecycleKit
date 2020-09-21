//
//  File.swift
//  
//
//  Created by Adam Share on 9/21/20.
//

import Foundation
@testable import Lifecycle
import XCTest

final class ViewLifecycleManagerTests: XCTestCase {
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

final class ViewLifecycleManaged: ViewLifecycleManageable, ViewLifecycleBindable {

    var viewDidLoadCount: Int = 0
    func viewDidLoad() {
        viewDidLoadCount += 1
    }
    
    var viewDidAppearCount: Int = 0
    func viewDidAppear() {
        viewDidAppearCount += 1
    }
    
    var viewDidDisappearCount: Int = 0
    func viewDidDisappear() {
        viewDidDisappearCount += 1
    }
}
