//
//  File.swift
//  
//
//  Created by Adam Share on 9/19/20.
//

@testable import Lifecycle
import XCTest
import SwiftUI

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

protocol TestLifecycleManageable: LifecycleManageable {}

final class TestLifecycleManageableMock: LifecycleManaged, TestLifecycleManageable {}

#if os(macOS)

    final class Delegate: NSObject, NSApplicationDelegate, RootLifecycleManager {
        var rootLifecycleManageable: LifecycleManageable = TestLifecycleManageableMock()
    }

#else
   
    final class Delegate: NSObject, UISceneDelegate, RootLifecycleManager {
        var rootLifecycleManageable: LifecycleManageable = TestLifecycleManageableMock()
    }

#endif
