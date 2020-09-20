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

public protocol LifecycleManageableRouting: AnyObject {
    /// All attached `LifecycleManageable`s.
    var children: [LifecycleManageable] { get }

    /// Attaches the given `LifecycleManageable` as a child.
    ///
    /// - parameter child: The child `LifecycleManageable` to attach.
    func attachChild(_ child: LifecycleManageable)

    /// Detaches the given `LifecycleManageable` from the tree.
    ///
    /// - parameter child: The child `LifecycleManageable` to detach.
    func detachChild(_ child: LifecycleManageable)
}

extension LifecycleManageableRouting where Self: LifecycleManageable {
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
}

extension LifecycleManageableRouting where Self: WeakLifecycleManageable {
    public var children: [LifecycleManageable] {
        return scopeLifecycleManager?.children ?? []
    }

    /// Attaches the given `LifecycleManageable` as a child.
    ///
    /// - parameter child: The child `LifecycleManageable` to attach.
    public func attachChild(_ child: LifecycleManageable) {
        scopeLifecycleManager?.attachChild(child)
    }

    /// Detaches the given `LifecycleManageable` from the tree.
    ///
    /// - parameter child: The child `LifecycleManageable` to detach.
    public func detachChild(_ child: LifecycleManageable) {
        scopeLifecycleManager?.detachChild(child)
    }
}
