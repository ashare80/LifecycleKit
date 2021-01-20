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
import SwiftUI

/// Convenience protocol for a `View ` with only a `Presenter` dependency.
public protocol PresenterView: View {
    /// `ObservableObject` presenter to bind to the `View` .
    associatedtype PresenterType: ObservableObject

    /// Initializes with an observable presenter.
    init(presenter: PresenterType)
}

public extension LifecycleOwnerViewProviding where Self: InteractablePresententerProviding, Presenter: ViewPresentable {
    var view: ModifiedContent<Presenter.ContentView, TrackingViewModifier> {
        return presenter.view
    }
}

public extension InteractablePresententerProviding where Self: LifecycleOwnerViewProviding {
    var lifecycleOwner: LifecycleOwner {
        return presentableInteractable
    }
}
