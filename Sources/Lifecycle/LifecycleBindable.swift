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

public protocol LifecycleBindable: AnyObject {
    /// The lifecycle did become active.
    ///
    /// - note: This method is driven by the attachment of this lifecycle's owner  Subclasses should override
    ///   this method to setup subscriptions and initial states.
    func didBecomeActive(_ lifecycleProvider: LifecycleProvider)

    /// Called when the lifecycle did become active for the first time.
    ///
    /// This method is invoked only once. Subclasses should override this method to perform one time setup logic,
    /// such as attaching immutable children. The default implementation does nothing.
    func didLoad(_ lifecycleProvider: LifecycleProvider)

    /// Callend when the `lifecycle` will resign the active state.
    ///
    /// This method is driven by the detachment of this lifecycle's owner  Subclasses should override this
    /// method to cleanup any resources and states of the `LifecycleBindable`. The default implementation does nothing.
    func didBecomeInactive()
}

extension LifecycleBindable {
    public func didBecomeActive(_ lifecycleProvider: LifecycleProvider) {}
    public func didBecomeInactive() {}
    public func didLoad(_ lifecycleProvider: LifecycleProvider) {}
}

extension LifecycleBindable where Self: LifecycleManageable {
    /// Binds to lifecycle events receiving on main thread and sets the receiver as the owner of the `ScopeLifecycleManager`.
    public func bind(to scopeLifecycleManager: ScopeLifecycleManager) {
        scopeLifecycleManager.owner = self
        bindActiveState(to: scopeLifecycleManager)
    }
}

extension LifecycleBindable {
    /// Binds to lifecycle states receiving on main thread.
    public func bind(to scopeLifecycleManager: ScopeLifecycleManager) {
        bindActiveState(to: scopeLifecycleManager)
    }

    /// Binds to lifecycle states receiving on main thread.
    fileprivate func bindActiveState(to scopeLifecycleManager: ScopeLifecycleManager) {
        if scopeLifecycleManager.binded.contains(self) {
            assertionFailure("Binding to \(scopeLifecycleManager) that has already been binded to. \(scopeLifecycleManager.binded)")
        }

        scopeLifecycleManager.binded.insert(self)

        scopeLifecycleManager
            .firstActive
            .receive(on: RunLoop.main)
            .autoCancel(scopeLifecycleManager, when: .deinitialized)
            // Weak to ensure binding to self does not cause retain cycle.
            .sink(receiveValue: { [weak self, weak scopeLifecycleManager] _ in
                guard let self = self, let scopeLifecycleManager = scopeLifecycleManager else { return }
                self.didLoad(scopeLifecycleManager)
            })

        scopeLifecycleManager
            .isActivePublisher
            .receive(on: RunLoop.main)
            .autoCancel(scopeLifecycleManager, when: .deinitialized)
            // Weak to ensure binding to self does not cause retain cycle.
            .sink(receiveValue: { [weak self, weak scopeLifecycleManager] isActive in
                guard let self = self, let scopeLifecycleManager = scopeLifecycleManager else { return }
                if isActive {
                    self.didBecomeActive(scopeLifecycleManager)
                } else {
                    self.didBecomeInactive()
                }
            })
    }
}
