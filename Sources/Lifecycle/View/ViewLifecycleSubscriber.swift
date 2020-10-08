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

public protocol ViewLifecycleSubscriber: AnyObject {
    /// Called when the view is first initialized.
    func viewDidLoad()

    /// Called when view receives `onAppear` callback.
    func viewDidAppear()

    /// Called when view receives `onDisappear` callback.
    func viewDidDisappear()
}

extension ViewLifecycleSubscriber {
    /// Binds to lifecycle states receiving on main thread.
    public func subscribe(to viewLifecycle: ViewLifecycle) {
        subscribeActiveState(viewLifecycle)
    }

    /// Binds to lifecycle states receiving on main thread.
    fileprivate func subscribeActiveState(_ viewLifecycle: ViewLifecycle) {
        if viewLifecycle.subscribers.contains(self) {
            assertionFailure("Binding to \(viewLifecycle) that has already been subscribes to. \(viewLifecycle.subscribers)")
        }
        viewLifecycle.subscribers.insert(self)

        viewLifecycle
            .lifecycleState
            .first(where: { $0 == .initialized })
            .receive(on: Schedulers.main)
            .autoCancel(viewLifecycle, when: .deinitialized)
            // Weak to ensure observing from owner does not cause retain cycle.
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewDidLoad()
            })

        viewLifecycle
            .isActivePublisher
            .drop(while: { !$0 })
            .receive(on: Schedulers.main)
            .autoCancel(viewLifecycle, when: .deinitialized)
            // Weak to ensure observing from owner does not cause retain cycle.
            .sink(receiveValue: { [weak self] isActive in
                guard let self = self else { return }
                if isActive {
                    self.viewDidAppear()
                } else {
                    self.viewDidDisappear()
                }
            })
    }
}
