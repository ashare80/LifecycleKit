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

/// The base protocol for all routers.
public protocol Routing: WeakLifecycleManageable {}

open class Router: WeakLifecycleManaged, LifecycleManageableRouting, Routing {}

/// Base class of an `Interactor` that has a separate associated `Presenter` and `View`.
open class PresentableRouter<PresenterType>: Router {
    public let presenter: PresenterType

    /// Initializer.
    ///
    /// - note: This holds a strong reference to the given `Presenter`.
    ///
    /// - parameter presenter: The presenter associated with this `Interactor`.
    public init(scopeLifecycleManager: ScopeLifecycleManager,
                presenter: PresenterType)
    {
        self.presenter = presenter
        super.init(scopeLifecycleManager: scopeLifecycleManager)

        if let viewLifecycleBindable = self as? ViewLifecycleBindable,
            let viewLifecycleManageable = presenter as? ViewLifecycleManageable {
            viewLifecycleBindable.bindViewAppearance(to: viewLifecycleManageable.viewLifecycleManager)
        }
    }
}
