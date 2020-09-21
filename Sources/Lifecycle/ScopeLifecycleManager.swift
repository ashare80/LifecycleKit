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
import CombineExtensions
import Foundation

/// Internalizes lifecycle management.
public final class ScopeLifecycleManager: LifecycleProvider, ObjectIdentifiable {
    public var lifecycleState: LifecycleState {
        return _lifecycleState
    }

    public var lifecyclePublisher: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> {
        return $_lifecycleState
            .eraseToAnyPublisher()
            .removeDuplicates()
    }

    weak var parent: ScopeLifecycleManager?
    weak var owner: LifecycleManageable? {
        didSet {
            if let owner = owner, let oldValue = oldValue, owner !== oldValue {
                assertionFailure("Already an owner for this manager: \(oldValue). \(ScopeLifecycleManager.self)s should only bind to a single \(LifecycleManageable.self). New value: \(owner)")
            }
        }
    }

    public init() {}

    deinit {
        if lifecycleState == .active {
            deactivate()
        }

        for child in children {
            detachChild(child)
        }

        _lifecycleState = .deinitialized

        LeakDetector.instance.expectDeallocate(objects: binded, inTime: .viewDisappearExpectation).retained.sink()
    }

    @Published private var _lifecycleState: LifecycleState = .initialized

    @Published var children: [LifecycleManageable] = []

    public internal(set) var binded = WeakSet<LifecycleBindable>()

    /// Activate this lifecycle scope including all children.
    func activate() {
        _lifecycleState = .active

        for lifecycleManageable in children where !lifecycleManageable.isActive {
            lifecycleManageable.scopeLifecycleManager.activate()
        }
    }

    /// Deactivate this lifecycle scope including all children.
    func deactivate() {
        _lifecycleState = .inactive

        for lifecycleManageable in children where lifecycleManageable.isActive {
            lifecycleManageable.scopeLifecycleManager.deactivate()
        }
    }

    /// Attaches the given `LifecycleManageable` as a child.
    ///
    /// - parameter child: The child `LifecycleManageable` to attach.
    func attachChild(_ child: LifecycleManageable) {
        guard child.scopeLifecycleManager.parent != self else {
            return
        }

        assert(child.scopeLifecycleManager != self, "Attempt to attach child: \(child), that is already managed at the local scope by \(self).")
        assert(child.scopeLifecycleManager.parent == nil, "Attempt to attach child: \(child), which is already attached as a child to \(String(describing: child.scopeLifecycleManager.parent)).")

        children.append(child)
        child.scopeLifecycleManager.parent = self

        if lifecycleState == .active {
            child.scopeLifecycleManager.activate()
        }
    }

    /// Detaches the given `LifecycleManageable` from the tree.
    ///
    /// - parameter child: The child `LifecycleManageable` to detach.
    func detachChild(_ child: LifecycleManageable) {
        guard child.scopeLifecycleManager.parent == self else { return }
        child.scopeLifecycleManager.parent = nil

        let removed = children.removeAllByReference(child)
        if removed, child.isActive {
            child.scopeLifecycleManager.deactivate()
        }
    }
}

extension ScopeLifecycleManager {
    /// Monitoring publisher to view `LifecycleManageable` hierarchy for tests and debugging tools.
    var childrenChangedPublisher: RelayPublisher<Void> {
        return $children
            .flatMap { (children: [LifecycleManageable]) -> Publishers.MergeMany<RelayPublisher<Void>> in
                Publishers.MergeMany(children.lazy.map { child -> RelayPublisher<Void> in
                    child.scopeLifecycleManager.childrenChangedPublisher
                })
            }
            .eraseToAnyPublisher()
    }
}
