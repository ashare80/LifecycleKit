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

public protocol ViewLifecycleManageable: AnyObject {
    /// View lifecycle tracking.
    var viewLifecycleManager: ViewLifecycleManager { get }
}

extension ViewLifecycleManageable {
    /// Tracks view by capturing `ViewLifecycleManager` inside `onAppear` and `onDisappear` closures of the returned` View`
    /// - parameter view: `View` type instance to track.
    /// - returns: `View` type after applying appearance closures.
    public func tracked<V: View>(_ view: V) -> some View {
        let viewLifecycleManager = self.viewLifecycleManager
        viewLifecycleManager.viewDidLoad = true

        return view.onAppear {
            viewLifecycleManager.isDisplayed = true
        }
        .onDisappear {
            viewLifecycleManager.isDisplayed = false
        }
    }
}

public final class ViewLifecycleManager: LifecycleProvider, ObjectIdentifiable {
    public var lifecycleState: LifecycleState {
        _lifecycleState
    }

    public var lifecyclePublisher: Publishers.RemoveDuplicates<RelayPublisher<LifecycleState>> {
        let statePublisher = $_lifecycleState
        return $viewDidLoad
            .drop(while: { didLoad in !didLoad })
            .first()
            .map { _ in statePublisher }
            .switchToLatest()
            .eraseToAnyPublisher()
            .removeDuplicates()
    }

    weak var owner: ViewLifecycleManageable? {
        didSet {
            if let owner = owner, let oldValue = oldValue, owner !== oldValue {
                assertionFailure("Already an owner for this manager: \(oldValue). \(ViewLifecycleManager.self)s should only bind to a single \(ViewLifecycleManageable.self). New value: \(owner)")
            }
        }
    }

    public init() {}

    deinit {
        _lifecycleState = .deinitialized
    }

    @Published var viewDidLoad: Bool = false

    /// Set to `true` `onAppear`, and `false` `onDisappear`.
    var isDisplayed: Bool = false {
        didSet {
            guard isDisplayed != oldValue else { return }

            _lifecycleState = isDisplayed ? .active : .inactive
        }
    }

    @Published private var _lifecycleState: LifecycleState = .initialized

    public internal(set) var binded = WeakSet<ViewLifecycleBindable>()
}

extension LifecycleProvider {
    /// Subscribes to lifecycle state and expects view to not be disaplyed when inactive.
    public func monitorViewDisappearWhenInactive(_ viewLifecycleManager: ViewLifecycleManager) {
        isActivePublisher
            .drop(while: { !$0 })
            .removeDuplicates()
            .map { isActive -> RelayPublisher<Void> in
                if isActive {
                    return Empty<Void, Never>().eraseToAnyPublisher()
                } else {
                    return LeakDetector.instance.expectViewDisappear(tracker: viewLifecycleManager)
                }
            }
            .switchToLatest()
            .retained
            .sink()
    }
}
