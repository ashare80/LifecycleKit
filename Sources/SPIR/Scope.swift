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
import Lifecycle

public protocol LifecycleManagedScope {
    /// Provided shared `ScopeLifecycleManager` for the component's scope.
    var scopeLifecycleManager: ScopeLifecycleManager { get }
    
    /// Provided shared `ViewLifecycleManager` for the component's scope.
    var viewLifecycleManager: ViewLifecycleManager { get }
}

/// Type for dependency frameworks such as Needle to conform to and provide a shared lifecycle instance.
public protocol LifecycleManagedScopeComponent: LifecycleManagedScope {
    /// Share the enclosed object as a singleton at this scope. This allows
    /// this scope as well as all child scopes to share a single instance of
    /// the object, for as long as this component lives.
    ///
    /// - note: Shared dependency's constructor should avoid switching threads
    /// as it may cause a deadlock.
    ///
    /// - parameter factory: The closure to construct the dependency object.
    /// - returns: The dependency object instance.
    func shared<T>(__function: String, _ factory: () -> T) -> T
}

extension LifecycleManagedScopeComponent {
    /// Provided shared `ScopeLifecycleManager` for the component's scope.
    public var scopeLifecycleManager: ScopeLifecycleManager {
        return shared(__function: #function) {
            return ScopeLifecycleManager()
        }
    }

    /// Provided shared `ViewLifecycleManager` for the component's scope.
    public var viewLifecycleManager: ViewLifecycleManager {
        return shared(__function: #function) {
            return ViewLifecycleManager()
        }
    }
}

#if canImport(NeedleFoundation)

import NeedleFoundation

public typealias EmptyDependency = NeedleFoundation.EmptyDependency
public typealias BootstrapComponent = NeedleFoundation.BootstrapComponent
public typealias Dependency = NeedleFoundation.Dependency
public typealias Component = NeedleFoundation.Component
public typealias Scope = NeedleFoundation.Scope

extension NeedleFoundation.Component: LifecycleManagedScopeComponent { }

#endif
