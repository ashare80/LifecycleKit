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

public protocol LifecycleSubscriber: AnyObject {
    /// The lifecycle did become active.
    ///
    /// - note: This method is driven by the attachment of this lifecycle's owner  Subclasses should override
    ///   this method to setup subscriptions and initial states.
    func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher)

    /// Called when the lifecycle did become active for the first time.
    ///
    /// This method is invoked only once. Subclasses should override this method to perform one time setup logic,
    /// such as attaching immutable children. The default implementation does nothing.
    func didLoad(_ lifecyclePublisher: LifecyclePublisher)

    /// Callend when the `lifecycle` will resign the active state.
    ///
    /// This method is driven by the detachment of this lifecycle's owner  Subclasses should override this
    /// method to cleanup any resources and states of the `LifecycleSubscriber`. The default implementation does nothing.
    func didBecomeInactive()
}

extension LifecycleSubscriber where Self: LifecycleOwner {
    /// Binds to lifecycle events receiving on main thread and sets the receiver as the owner of the `ScopeLifecycle`.
    public func subscribe(_ scopeLifecycle: ScopeLifecycle) {
        scopeLifecycle.owner = self
        subscribeActiveState(scopeLifecycle)
    }
}

extension LifecycleSubscriber {
    /// Binds to lifecycle states receiving on main thread.
    public func subscribe(_ scopeLifecycle: ScopeLifecycle) {
        subscribeActiveState(scopeLifecycle)
    }

    /// Binds to lifecycle states receiving on main thread.
    fileprivate func subscribeActiveState(_ scopeLifecycle: ScopeLifecycle) {
        if scopeLifecycle.subscribers.contains(self) {
            assertionFailure("Binding to \(scopeLifecycle) that has already been subscribes to. \(scopeLifecycle.subscribers)")
        }

        scopeLifecycle.subscribers.insert(self)

        scopeLifecycle
            .firstActive
            .receive(on: Schedulers.main)
            .autoCancel(scopeLifecycle, when: .deinitialized)
            // Weak to ensure observing from owner does not cause retain cycle.
            .sink(receiveValue: { [weak self, weak scopeLifecycle] _ in
                guard let self = self, let scopeLifecycle = scopeLifecycle else { return }
                self.didLoad(scopeLifecycle)
            })

        scopeLifecycle
            .isActivePublisher
            .drop(while: { !$0 })
            .receive(on: Schedulers.main)
            .autoCancel(scopeLifecycle, when: .deinitialized)
            // Weak to ensure observing from owner does not cause retain cycle.
            .sink(receiveValue: { [weak self, weak scopeLifecycle] isActive in
                guard let self = self, let scopeLifecycle = scopeLifecycle else { return }
                if isActive {
                    self.didBecomeActive(scopeLifecycle)
                } else {
                    self.didBecomeInactive()
                }
            })
    }
}
