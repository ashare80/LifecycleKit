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

public protocol LifecycleOwnerScope {
    /// Provided shared `ScopeLifecycle` for the component's scope.
    var scopeLifecycle: ScopeLifecycle { get }
}

/// Type for dependency frameworks such as Needle to conform to and provide a shared lifecycle instance.
public protocol LifecycleOwnerScopeComponent: LifecycleOwnerScope {
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

extension LifecycleOwnerScopeComponent {
    /// Provided shared `ScopeLifecycle` for the component's scope.
    public var scopeLifecycle: ScopeLifecycle {
        return shared(__function: #function) {
            return ScopeLifecycle()
        }
    }

    /// Allows a shared parent instance to be passed by DI to a child scope and avoid a circular reference from parentScope->shared->childScope->parentScope.
    public func weakShared<T: AnyObject>(__function: String = #function, _ factory: () -> T) -> T {
        return shared(__function: __function) { WeakShared(factory) }.instance
    }
}

/// Weakly holds reference to the lazily created value.
final class WeakShared<R: AnyObject> {
    private var tempInstance: R?
    private weak var weakInstance: R?

    /// Initializer.
    ///
    /// - parameter builder: The building closure that creates a new instance of `R` on each call to build.
    public init(_ builder: () -> R) {
        self.tempInstance = builder()
    }

    /// Builds a new instance of `R`.
    public var instance: R {
        if let tempInstance = tempInstance {
            defer { self.tempInstance = nil }
            weakInstance = tempInstance
            return tempInstance
        }

        if let weakInstance = weakInstance {
            return weakInstance
        }

        fatalError("Attempting to access instance from scope that has been deinitialized.")
    }
}

#if canImport(NeedleFoundation)

    import NeedleFoundation

    public typealias EmptyDependency = NeedleFoundation.EmptyDependency
    public typealias BootstrapComponent = NeedleFoundation.BootstrapComponent
    public typealias Dependency = NeedleFoundation.Dependency
    public typealias Component = NeedleFoundation.Component
    public typealias Scope = NeedleFoundation.Scope

    extension NeedleFoundation.Component: LifecycleOwnerScopeComponent {}

#endif
