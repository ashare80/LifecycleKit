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
import Foundation
import Lifecycle

/// The base protocol for all interactors.
public protocol Interactable: LifecycleManageable {}

/// An `Interactor` defines a unit of business logic that corresponds to a interactable unit.
///
/// An `Interactor` has a lifecycle driven by its owner  When the corresponding interactable is attached to its
/// parent, its interactor becomes active. And when the interactable is detached from its parent, its `Interactor` resigns
/// active.
///
/// An `Interactor` should only perform its business logic when it's currently active.
open class Interactor: LifecycleManaged, Interactable {}

/// Interactor subclass that  `Router`
open class RoutingInteractor<RouterType>: Interactor {
    public let router: RouterType
    
    public init(scopeLifecycleManager: ScopeLifecycleManager,
                router: RouterType)
    {
        self.router = router
        super.init(scopeLifecycleManager: scopeLifecycleManager)
    }
}

extension RoutingInteractor {
    /// Testable convenience init.
    convenience init(router: RouterType) {
        self.init(scopeLifecycleManager: ScopeLifecycleManager(),
                  router: router)
    }
}

/// `Interactor` that provides a `View`
public protocol PresentableInteractable: Interactable, Presentable {}

/// Base class of an `Interactor` that has a separate associated `Presenter` and `View`.
open class PresentableInteractor<PresenterType>: Interactor, PresentableInteractable, ViewLifecycleBindable {
    public let presenter: PresenterType

    private let presentable: Presentable

    public var viewable: Viewable {
        return presentable.viewable
    }

    public var viewLifecycleManager: ViewLifecycleManager {
        return presentable.viewLifecycleManager
    }

    /// Initializer.
    ///
    /// - note: This holds a strong reference to the given `Presenter`.
    ///
    /// - parameter presenter: The presenter associated with this `Interactor`.
    public init(scopeLifecycleManager: ScopeLifecycleManager,
                presenter: PresenterType,
                viewLifecycleManager: ViewLifecycleManager)
    {
        self.presenter = presenter
        guard let presentable = presenter as? Presentable else {
            fatalError("\(presenter)")
        }
        self.presentable = presentable
        super.init(scopeLifecycleManager: scopeLifecycleManager)
        bindViewAppearance(to: viewLifecycleManager)
    }

    deinit {
        expectDeallocate(ownedObject: presenter as AnyObject, inTime: .viewDisappearExpectation)
    }
}

extension PresentableInteractor {
    /// Testable convenience init.
    convenience init(presenter: PresenterType,
                     viewLifecycleManager: ViewLifecycleManager = ViewLifecycleManager()) {
        self.init(scopeLifecycleManager: ScopeLifecycleManager(),
                  presenter: presenter,
                  viewLifecycleManager: viewLifecycleManager)
    }
}

extension PresentableInteractable where Self: Presentable {
    public var presentable: Presentable {
        return self
    }
}

open class PresentableRoutingInteractor<PresenterType, RouterType>: PresentableInteractor<PresenterType> {
    public let router: RouterType
    
    public init(scopeLifecycleManager: ScopeLifecycleManager,
                presenter: PresenterType,
                router: RouterType,
                viewLifecycleManager: ViewLifecycleManager)
    {
        self.router = router
        super.init(scopeLifecycleManager: scopeLifecycleManager,
                   presenter: presenter,
                   viewLifecycleManager: viewLifecycleManager)
    }

    deinit {
        expectDeallocate(ownedObject: router as AnyObject)
    }
}

extension PresentableRoutingInteractor {
    /// Testable convenience init.
    convenience init(presenter: PresenterType,
                     router: RouterType,
                     viewLifecycleManager: ViewLifecycleManager = ViewLifecycleManager()) {
        self.init(scopeLifecycleManager: ScopeLifecycleManager(),
                  presenter: presenter,
                  router: router,
                  viewLifecycleManager: viewLifecycleManager)
    }
}
