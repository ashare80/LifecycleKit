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

    public var children: [LifecycleManageable] {
        return scopeLifecycleManager.children
    }

    /// Attaches the given `LifecycleManageable` as a child.
    ///
    /// - parameter child: The child `LifecycleManageable` to attach.
    public func attachChild(_ child: LifecycleManageable) {
        scopeLifecycleManager.attachChild(child)
    }

    /// Detaches the given `LifecycleManageable` from the tree.
    ///
    /// - parameter child: The child `LifecycleManageable` to detach.
    public func detachChild(_ child: LifecycleManageable) {
        scopeLifecycleManager.detachChild(child)
    }

    public func expectDeallocate(ownedObject: AnyObject, inTime time: TimeInterval = .deallocationExpectation) {
        if let lifecycleManagedRouter = ownedObject as? LifecycleManageable {
            if lifecycleManagedRouter.scopeLifecycleManager === scopeLifecycleManager {
                LeakDetector.instance.expectDeallocate(object: ownedObject, inTime: time).retained.sink()
            }
        } else {
            LeakDetector.instance.expectDeallocate(object: ownedObject, inTime: time).retained.sink()
        }
    }
}

open class LifecycleManaged: LifecycleManageable, LifecycleBindable {
    public let scopeLifecycleManager: ScopeLifecycleManager

    /// Initializer.
    public init(scopeLifecycleManager: ScopeLifecycleManager = ScopeLifecycleManager()) {
        self.scopeLifecycleManager = scopeLifecycleManager
        bindActiveState(to: scopeLifecycleManager)
    }
}
