//
//  Copyright (c) 2021. Adam Share
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

/// The base builder protocol that all builders should conform to.
public protocol Buildable: AnyObject {}

/// Utility that instantiates a RIB and sets up its internal wirings.
open class Builder<DependencyType>: Buildable {

    /// The dependency used for this builder to build the RIB.
    public let dependency: DependencyType

    /// Initializer.
    ///
    /// - parameter dependency: The dependency used for this builder to build the RIB.
    public init(dependency: DependencyType) {
        self.dependency = dependency
    }
}

/// Builds a new `Routing` instance.
public protocol RoutingBuildable: AnyObject {
    /// Builds a new `Routing` instance.
    func build() -> Routing
}

/// Builds a new `ViewableRouting` instance.
public protocol ViewableRoutingBuildable: AnyObject {
    /// Builds a new `ViewableRouting` instance.
    func build() -> ViewableRouting
}

extension AnyBuilder: RoutingBuildable where R == Routing {}
extension AnyBuilder: ViewableRoutingBuildable where R == ViewableRouting {}

/// Builds a new `Routing` instance.
public protocol LazyRouting: AnyObject {
    /// Builds a new `Routing` instance.
    var value: Routing { get }
}

/// Builds a new `ViewableRouting` instance.
public protocol LazyViewableRouting: AnyObject {
    /// Builds a new `ViewableRouting` instance.
    var value: ViewableRouting { get }
}

extension Lazy: RoutingBuildable where R == Routing {
    public func build() -> Routing {
        return getOrCreate()
    }
}

extension Lazy: ViewableRoutingBuildable where R == ViewableRouting {
    public func build() -> ViewableRouting {
        return getOrCreate()
    }
}

extension Lazy: LazyRouting where R == Routing {
    public var value: Routing {
        return getOrCreate()
    }
}

extension Lazy: LazyViewableRouting where R == ViewableRouting {
    public var value: ViewableRouting {
        return getOrCreate()
    }
}

extension WeakLazy: RoutingBuildable where R: Routing {
    public func build() -> Routing {
        return getOrCreate()
    }
}

extension WeakLazy: ViewableRoutingBuildable where R: ViewableRouting {
    public func build() -> ViewableRouting {
        return getOrCreate()
    }
}

extension WeakLazy: LazyRouting where R: Routing {
    public var value: Routing {
        return getOrCreate()
    }
}

extension WeakLazy: LazyViewableRouting where R: ViewableRouting {
    public var value: ViewableRouting {
        return getOrCreate()
    }
}

public extension AnyBuilder where R == ViewableRouting {
    convenience init(viewableRouting: @escaping @autoclosure () -> ViewableRouting) {
        self.init { () -> ViewableRouting in
            return viewableRouting()
        }
    }
}
