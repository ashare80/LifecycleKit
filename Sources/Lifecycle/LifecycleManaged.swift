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

open class LifecycleManaged: ObjectIdentifiable, LifecycleManageable, LifecycleBindable {
    public let scopeLifecycleManager: ScopeLifecycleManager

    /// Initializer.
    public init(scopeLifecycleManager: ScopeLifecycleManager = ScopeLifecycleManager()) {
        self.scopeLifecycleManager = scopeLifecycleManager
        bindActiveState(to: scopeLifecycleManager)
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

open class WeakLifecycleManaged: ObjectIdentifiable, WeakLifecycleManageable, LifecycleBindable {
    public weak var scopeLifecycleManager: ScopeLifecycleManager?

    /// Initializer.
    public init(scopeLifecycleManager: ScopeLifecycleManager) {
        self.scopeLifecycleManager = scopeLifecycleManager
        bindActiveState(to: scopeLifecycleManager)
    }
}
