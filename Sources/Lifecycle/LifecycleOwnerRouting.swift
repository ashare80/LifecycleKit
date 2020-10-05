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

public protocol LifecycleOwnerRouting: AnyObject {
    /// All attached `LifecycleOwner`s.
    var children: [LifecycleOwner] { get }

    /// Attaches the given `LifecycleOwner` as a child.
    ///
    /// The child will activate if the receiver is active.
    /// Child activation may run logic that synchornously results in a call to detach before `attachChild` returns.
    /// Best practice is to ensure the return value is`true` before performing additional routing logic such as presenting views.
    ///
    /// - parameter child: The child `LifecycleOwner` to attach.
    /// - returns: Is `true` if child was successfully attached.
    @discardableResult
    func attachChild(_ child: LifecycleOwner) -> Bool

    /// Detaches the given `LifecycleOwner` from the tree.
    ///
    /// - parameter child: The child `LifecycleOwner` to detach.
    func detachChild(_ child: LifecycleOwner)
}

extension LifecycleOwnerRouting where Self: LifecycleOwner {
    public var children: [LifecycleOwner] {
        return scopeLifecycle.children
    }

    /// Attaches the given `LifecycleOwner` as a child.
    ///
    /// The child will activate if the receiver is active.
    /// Child activation may run logic that synchornously results in a call to detach before `attachChild` returns.
    /// Best practice is to ensure the return value is`true` before performing additional routing logic such as presenting views.
    ///
    /// - parameter child: The child `LifecycleOwner` to attach.
    /// - returns: Is `true` if child was successfully attached.
    @discardableResult
    public func attachChild(_ child: LifecycleOwner) -> Bool {
        return scopeLifecycle.attachChild(child)
    }

    /// Detaches the given `LifecycleOwner` from the tree.
    ///
    /// - parameter child: The child `LifecycleOwner` to detach.
    public func detachChild(_ child: LifecycleOwner) {
        scopeLifecycle.detachChild(child)
    }
}

extension LifecycleOwnerRouting where Self: LifecycleDependent {
    public var children: [LifecycleOwner] {
        return scopeLifecycle?.children ?? []
    }

    /// Attaches the given `LifecycleOwner` as a child.
    ///
    /// The child will activate if the receiver is active.
    /// Child activation may run logic that synchornously results in a call to detach before `attachChild` returns.
    /// Best practice is to ensure the return value is`true` before performing additional routing logic such as presenting views.
    ///
    /// - parameter child: The child `LifecycleOwner` to attach.
    /// - returns: Is `true` if child was successfully attached.
    @discardableResult
    public func attachChild(_ child: LifecycleOwner) -> Bool {
        return scopeLifecycle?.attachChild(child) ?? false
    }

    /// Detaches the given `LifecycleOwner` from the tree.
    ///
    /// - parameter child: The child `LifecycleOwner` to detach.
    public func detachChild(_ child: LifecycleOwner) {
        scopeLifecycle?.detachChild(child)
    }
}
