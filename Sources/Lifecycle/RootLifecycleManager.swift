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

/// The root `LifecycleManager` of an application.
public protocol RootLifecycleManager {
    associatedtype Root: LifecycleManageable
    var root: Root { get }
}

#if os(macOS)

extension NSApplicationDelegate where Self: RootLifecycleManager {
    func activateRoot() {
        root.scopeLifecycleManager.activate()
    }

    func deactivateRoot() {
        root.scopeLifecycleManager.deactivate()
    }
}

#else

extension UIApplicationDelegate where Self: RootLifecycleManager {
    func activateRoot() {
        root.scopeLifecycleManager.activate()
    }

    func deactivateRoot() {
        root.scopeLifecycleManager.deactivate()
    }
}

extension UISceneDelegate where Self: RootLifecycleManager {
    func activateRoot() {
        root.scopeLifecycleManager.activate()
    }

    func deactivateRoot() {
        root.scopeLifecycleManager.deactivate()
    }
}

#endif
