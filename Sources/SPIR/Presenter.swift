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
import SwiftUI

/// Type erased `Presenter`.
public protocol Presentable: ViewLifecycleManageable {
    /// Type erased view for public use.
    var viewable: Viewable { get }
}

/// The base protocol for all `Presenter`s.
public protocol Presenting: ViewLifecycleManageable, ViewLifecycleBindable { }

/// The base class of all `Presenter`s. A `Presenter` translates business models into values the corresponding
/// `View` can consume and display. It also maps UI events to business logic method, invoked to
/// its listener.
open class Presenter<View>: ObjectIdentifiable, Presenting {
    public typealias ViewType = View

    public let viewLifecycleManager: ViewLifecycleManager
    
    public init(viewLifecycleManager: ViewLifecycleManager = ViewLifecycleManager())
    {
        self.viewLifecycleManager = viewLifecycleManager
        bindViewAppearance(to: viewLifecycleManager)
    }
}

open class InteractablePresenter<View>: Presenter<View>, Interactable {
    public let scopeLifecycleManager: ScopeLifecycleManager

    /// Initializer.
    public init(scopeLifecycleManager: ScopeLifecycleManager = ScopeLifecycleManager(),
                         viewLifecycleManager: ViewLifecycleManager = ViewLifecycleManager())
    {
        self.scopeLifecycleManager = scopeLifecycleManager
        super.init(viewLifecycleManager: viewLifecycleManager)
        scopeLifecycleManager.monitorViewDisappearWhenInactive(viewLifecycleManager)
    }
}

/// Conformance by `Presenter` subclasses to provide a `ViewType` and be an `ObservableObject`.
public protocol ViewPresentable: Presentable, ObservableObject {
    /// View type confroming to `View`.
    associatedtype ViewType: View

    /// Typed view for internal reference.
    var view: ViewType { get }
}

extension ViewPresentable where ViewType: PresenterView, ViewType.PresenterType == Self {
    public var view: ViewType {
        return ViewType(presenter: self)
    }
}

extension ViewPresentable {
    /// The corresponding `View` owned by this `Presenter`.
    public var viewable: Viewable {
        return tracked(view).asAnyView
    }
}
