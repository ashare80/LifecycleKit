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
import CombineExtensions
import Foundation
import SwiftUI

/// Creates an active lifecycle that deactivates when released.
final class ReferenceLifecycleOwner: ObjectIdentifiable, LifecycleOwner, LifecycleOwnerRouting {
    public let scopeLifecycle: ScopeLifecycle = ScopeLifecycle()
    deinit {
        scopeLifecycle.deactivate()
    }
}

public protocol ViewProvidingScope {
    associatedtype ContentView: View
    var lifecycleOwner: LifecycleOwner { get }
    var view: ContentView { get }
    var scopeView: ScopeView<ContentView> { get }
}

extension ViewProvidingScope {
    public var scopeView: ScopeView<ContentView> {
        let scopeView = ScopeView(body: view, childLifecycle: lifecycleOwner)
        return scopeView
    }
}

/// Lifecycle active as long as the view is referenced.
public struct ScopeView<ContentView: View>: View, Hashable, Viewable {
    private let lifecycle: ReferenceLifecycleOwner = ReferenceLifecycleOwner()
    
    public let body: ContentView
    public let childLifecycle: LifecycleOwner
    
    public init(body: ContentView,
                childLifecycle: LifecycleOwner) {
        self.body = body
        self.childLifecycle = childLifecycle
        lifecycle.attachChild(childLifecycle)
        lifecycle.activate()
    }
    
    public static func == (lhs: ScopeView, rhs: ScopeView) -> Bool {
        lhs.lifecycle === rhs.lifecycle
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(lifecycle))
    }
}

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

extension View {
    public var asAnyView: AnyView {
        return AnyView(self)
    }
}
