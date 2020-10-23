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

import CombineExtensions
import Foundation

/// Type that builds with no added dependencies..
public protocol Buildable: AnyObject {
    /// Return type from build function.
    associatedtype R

    /// Builds a new instance of `R`.
    func build() -> R
}

/// Type erased builder of new `R` instances.
public final class AnyBuilder<R>: ObjectIdentifiable, Buildable {
    private let builder: () -> R

    /// Initializer.
    ///
    /// - parameter builder: The building closure that creates a new instance of `R` on each call to build.
    public init(_ builder: @escaping () -> R) {
        self.builder = builder
    }

    /// Builds a new instance of `R`.
    public func build() -> R {
        return builder()
    }
}

/// Type that builds with a dynamic dependency.
public protocol DynamicBuildable: AnyObject {
    /// Type of dynami dependency the builder needs to create an instance.
    associatedtype DynamicDependency

    /// Return type from build function.
    associatedtype R

    /// Builds a new instance of `R`.
    ///
    /// - parameter dynamicDependency: The dynamic dependency that could not be injected.
    /// - returns: New instance of `R`.
    func build(_ dynamicDependency: DynamicDependency) -> R
}

extension DynamicBuildable {
    /// Wraps with dynamic dependancy to`AnyBuilder<R>` for deferred building.
    ///
    /// - parameter dynamicDependency: The dynamic dependency that could not be injected.
    /// - returns: Wrapped builder of type `AnyBuilder<R>`.
    public func asAnyBuilder(_ dynamicDependency: DynamicDependency) -> AnyBuilder<R> {
        return AnyBuilder { self.build(dynamicDependency) }
    }
}

/// Type erased builder of new `R` instances with a dynamic build time dependency.
public final class AnyDynamicBuilder<DynamicDependency, R>: ObjectIdentifiable, DynamicBuildable {
    private let builder: (DynamicDependency) -> R

    /// Initializer.
    ///
    /// - parameter builder: The building closure that creates a new instance of `R` on each call to build.
    public init(_ builder: @escaping (DynamicDependency) -> R) {
        self.builder = builder
    }

    /// Builds a new instance of `R`.
    ///
    /// - parameter dynamicDependency: The dynamic dependency that could not be injected.
    /// - returns: New instance of `R`.
    public func build(_ dynamicDependency: DynamicDependency) -> R {
        return builder(dynamicDependency)
    }
}

/// Type that builds with no added dependencies..
public protocol CachedBuildable: AnyObject {
    /// Return type from build function.
    associatedtype R

    /// Builds a new instance of `R`.
    func getOrCreate() -> R
}

public protocol WeakCachedBuildable: CachedBuildable {
    var instance: R? { get }
}

public protocol LazyValue: CachedBuildable {
    var value: R { get }
}

extension LazyValue {
    public var value: R {
        return getOrCreate()
    }
}

/// Weakly holds reference to the lazily created value.
public final class WeakCachedBuilder<R: AnyObject>: ObjectIdentifiable, WeakCachedBuildable, LazyValue {

    public weak var instance: R?

    private let builder: () -> R
    private let lock: NSRecursiveLock = NSRecursiveLock()

    /// Initializer.
    ///
    /// - parameter builder: The building closure that creates a new instance of `R` on each call to build.
    public init(_ builder: @escaping () -> R) {
        self.builder = builder
    }

    /// Builds a new instance of `R`.
    public func getOrCreate() -> R {
        lock.lock(); defer { lock.unlock() }

        if let instance = instance {
            return instance
        } else {
            let newInstance = builder()
            instance = newInstance
            return newInstance
        }
    }
}

/// Holds a strong reference to the lazily created value.
public final class CachedBuilder<R>: ObjectIdentifiable, CachedBuildable {

    public var value: R {
        return getOrCreate()
    }

    private let builder: () -> R
    private var instance: R?
    private let lock: NSRecursiveLock = NSRecursiveLock()

    /// Initializer.
    ///
    /// - parameter builder: The building closure that creates a new instance of `R` on each call to build.
    public init(_ builder: @escaping () -> R) {
        self.builder = builder
    }

    /// Builds a new instance of `R`.
    public func getOrCreate() -> R {
        lock.lock(); defer { lock.unlock() }

        if let instance = instance {
            return instance
        } else {
            let newInstance = builder()
            instance = newInstance
            return newInstance
        }
    }
}
