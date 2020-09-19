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

/// Type that builds with no added dependencies..
public protocol Buildable: AnyObject {
    /// Return type from build function.
    associatedtype R

    /// Builds a new instance of `R`.
    func build() -> R
}

/// Type erased
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

/// The base builder protocol that all builders should conform to.
public protocol InteractableBuildable: AnyObject {
    func build() -> Interactable
}

/// The base builder protocol that all builders should conform to.
public protocol PresentableInteractableBuildable: AnyObject {
    func build() -> PresentableInteractable
}

extension AnyBuilder: InteractableBuildable where R == Interactable {}
extension AnyBuilder: PresentableInteractableBuildable where R == PresentableInteractable {}

/// Type that builds with a dynamic dependency.
public protocol DynamicBuildable: AnyObject {
    /// Type of dynami dependency the builder needs to create an instance.
    associatedtype DynamicDependency

    /// Return type from build function.
    associatedtype R

    /// Builds a new instance of `R`.
    ///
    /// - parameter dynamicDependency: The dynamic dependency that could not be injected.
    func build(_ dynamicDependency: DynamicDependency) -> R
}

/// Type erased
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
    public func build(_ dynamicDependency: DynamicDependency) -> R {
        return builder(dynamicDependency)
    }
}
