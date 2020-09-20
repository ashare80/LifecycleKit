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

public protocol ViewLifecycleBindable: AnyObject {
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
}

extension ViewLifecycleBindable {
    public func viewDidLoad() {}
    public func viewDidAppear() {}
    public func viewDidDisappear() {}
}

extension ViewLifecycleBindable {
    public func bind(to viewLifecycleManager: ViewLifecycleManager) {
        if viewLifecycleManager.binded.contains(self) {
            assertionFailure("Binding to \(viewLifecycleManager) that has already been binded to. \(viewLifecycleManager.binded)")
        }
        viewLifecycleManager.binded.insert(self)

        viewLifecycleManager
            .lifecyclePublisher
            .first(where: { $0 == .initialized })
            .receive(on: RunLoop.main)
            .autoCancel(viewLifecycleManager, when: .deinitialized)
            // Weak to ensure binding to self does not cause retain cycle.
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewDidLoad()
            })

        viewLifecycleManager
            .isActivePublisher
            .receive(on: RunLoop.main)
            .autoCancel(viewLifecycleManager, when: .deinitialized)
            // Weak to ensure binding to self does not cause retain cycle.
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
