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

/// Builds a new `Interactable` instance.
public protocol InteractableBuildable: AnyObject {
    /// Builds a new `Interactable` instance.
    func build() -> Interactable
}

/// Builds a new `PresentableInteractable` instance.
public protocol PresentableInteractableBuildable: AnyObject {
    /// Builds a new `PresentableInteractable` instance.
    func build() -> PresentableInteractable
}

extension AnyBuilder: InteractableBuildable where R == Interactable {}
extension AnyBuilder: PresentableInteractableBuildable where R == PresentableInteractable {}

/// Builds a new `Interactable` instance.
public protocol LazyInteractable: AnyObject {
    /// Builds a new `Interactable` instance.
    var value: Interactable { get }
}

/// Builds a new `PresentableInteractable` instance.
public protocol LazyPresentableInteractable: AnyObject {
    /// Builds a new `PresentableInteractable` instance.
    var value: PresentableInteractable { get }
}

extension Lazy: InteractableBuildable where R == Interactable {
    public func build() -> Interactable {
        return getOrCreate()
    }
}

extension Lazy: PresentableInteractableBuildable where R == PresentableInteractable {
    public func build() -> PresentableInteractable {
        return getOrCreate()
    }
}

extension Lazy: LazyInteractable where R == Interactable {
    public var value: Interactable {
        return getOrCreate()
    }
}

extension Lazy: LazyPresentableInteractable where R == PresentableInteractable {
    public var value: PresentableInteractable {
        return getOrCreate()
    }
}

extension WeakLazy: InteractableBuildable where R: Interactable {
    public func build() -> Interactable {
        return getOrCreate()
    }
}

extension WeakLazy: PresentableInteractableBuildable where R: PresentableInteractable {
    public func build() -> PresentableInteractable {
        return getOrCreate()
    }
}

extension WeakLazy: LazyInteractable where R: Interactable {
    public var value: Interactable {
        return getOrCreate()
    }
}

extension WeakLazy: LazyPresentableInteractable where R: PresentableInteractable {
    public var value: PresentableInteractable {
        return getOrCreate()
    }
}

public protocol PresenterProviding {
    associatedtype Presenter: Presentable

    var presenter: Presenter { get }
}

public protocol InteractablePresententerProviding: PresenterProviding, PresentableInteractableConvertible, PresentableInteractableBuildable where Presenter: PresentableInteractable {}

extension InteractablePresententerProviding {
    public var presentableInteractable: PresentableInteractable {
        return presenter
    }

    public func build() -> PresentableInteractable {
        return presentableInteractable
    }
}

public protocol InteractorProviding: InteractableConvertible {
    associatedtype Interactor: Interactable

    var interactor: Interactor { get }
}

extension InteractorProviding {
    public var interactable: Interactable {
        return interactor
    }
}

public protocol PresentableInteractorProviding: InteractorProviding, PresentableInteractableConvertible, PresentableInteractableBuildable where Interactor: PresentableInteractable {}

extension PresentableInteractorProviding {
    public var presentableInteractable: PresentableInteractable {
        return interactor
    }

    public func build() -> PresentableInteractable {
        return presentableInteractable
    }
}

extension AnyBuilder where R == PresentableInteractable {
    public convenience init(presentableInteractable: @escaping @autoclosure () -> PresentableInteractable) {
        self.init { () -> PresentableInteractable in
            return presentableInteractable()
        }
    }

    public convenience init(component: @escaping @autoclosure () -> PresentableInteractableConvertible) {
        self.init { () -> PresentableInteractable in
            return component().presentableInteractable
        }
    }
}
