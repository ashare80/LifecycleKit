//
//  File.swift
//  
//
//  Created by Adam Share on 9/21/20.
//

import Foundation
import Combine
import CombineExtensions

public protocol LifecycleManageable: LifecycleProvider {
    /// Internal manager of lifecycle events.
    var scopeLifecycleManager: ScopeLifecycleManager { get }
}

extension LifecycleManageable {
    public var lifecycleState: LifecycleState {
        return scopeLifecycleManager.lifecycleState
    }

    public var lifecyclePublisher: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> {
        return scopeLifecycleManager.lifecyclePublisher
    }

    public func expectDeallocateIfOwns(_ ownedObject: AnyObject, inTime time: TimeInterval = .deallocationExpectation) {
        if let lifecycleManaged = ownedObject as? LifecycleManageable {
            guard lifecycleManaged.scopeLifecycleManager === scopeLifecycleManager else { return }
        }

        LeakDetector.instance.expectDeallocate(object: ownedObject, inTime: time).retained.sink()
    }
}

public protocol WeakLifecycleManageable: LifecycleProvider {
    /// Internal manager of lifecycle events.
    var scopeLifecycleManager: ScopeLifecycleManager? { get }
}

extension WeakLifecycleManageable {
    public var lifecycleState: LifecycleState {
        return scopeLifecycleManager?.lifecycleState ?? .deinitialized
    }

    public var lifecyclePublisher: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> {
        return scopeLifecycleManager?.lifecyclePublisher ?? Just<LifecycleState>(.deinitialized).eraseToAnyPublisher().removeDuplicates()
    }

    public func expectDeallocateIfOwns(_ ownedObject: AnyObject, inTime time: TimeInterval = .deallocationExpectation) {
        if let lifecycleManaged = ownedObject as? LifecycleManageable {
            guard lifecycleManaged.scopeLifecycleManager === scopeLifecycleManager else { return }
        }

        LeakDetector.instance.expectDeallocate(object: ownedObject, inTime: time).retained.sink()
    }
}
