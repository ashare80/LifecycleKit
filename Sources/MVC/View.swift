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
import SwiftUI

/// Type erased `View`.
public protocol Viewable {
    /// Wraps in `AnyView`.
    var asAnyView: AnyView { get }
}

extension AnyView: Viewable {
    public var asAnyView: AnyView {
        return self
    }
}

/// Convenience protocol for a `View ` with only a `Presenter` dependency.
public protocol PresenterView: View {
    /// `ObservableObject` presenter to bind to the `View` .
    associatedtype PresenterType: ObservableObject

    /// Initializes with an observable presenter.
    init(presenter: PresenterType)
}

extension View {
    public var asAnyView: AnyView {
        return AnyView(self)
    }
}
