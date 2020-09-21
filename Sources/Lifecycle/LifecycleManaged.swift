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

/// Base class to conform to `LifecycleManageable` binding as the owner of a `ScopeLifecycleManager`.
open class LifecycleManaged: ObjectIdentifiable, LifecycleManageable, LifecycleManageableRouting, LifecycleBindable {
    public let scopeLifecycleManager: ScopeLifecycleManager

    /// Initializer.
    public init(scopeLifecycleManager: ScopeLifecycleManager = ScopeLifecycleManager()) {
        self.scopeLifecycleManager = scopeLifecycleManager
        bind(to: scopeLifecycleManager)
    }

    open func didLoad(_ lifecycleProvider: LifecycleProvider) {}

    open func didBecomeActive(_ lifecycleProvider: LifecycleProvider) {}

    open func didBecomeInactive() {}
}

/// Base class to conform to `WeakLifecycleManageable` binding with a weak reference to a `ScopeLifecycleManager`.
open class WeakLifecycleManaged: ObjectIdentifiable, WeakLifecycleManageable, LifecycleManageableRouting, LifecycleBindable {
    public weak var scopeLifecycleManager: ScopeLifecycleManager?

    /// Initializer.
    public init(scopeLifecycleManager: ScopeLifecycleManager) {
        self.scopeLifecycleManager = scopeLifecycleManager
        bind(to: scopeLifecycleManager)
    }

    open func didLoad(_ lifecycleProvider: LifecycleProvider) {}

    open func didBecomeActive(_ lifecycleProvider: LifecycleProvider) {}

    open func didBecomeInactive() {}
}
