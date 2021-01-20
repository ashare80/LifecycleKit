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

import SPIR

protocol RootPresentable: Presentable {
    func present(presenter: Presentable)
    func dismiss(presenter: Presentable)
}

final class RootRouter: PresentableRouter<RootPresentable>, RootRouting {

    private var loggedOut: PresentableInteractable?

    private let loggedOutBuilder: PresentableInteractableBuildable
    private let loggedInBuilder: LoggedInBuildable

    init(scopeLifecycle: ScopeLifecycle,
         presenter: RootPresentable,
         loggedOutBuilder: PresentableInteractableBuildable,
         loggedInBuilder: LoggedInBuildable)
    {
        self.loggedOutBuilder = loggedOutBuilder
        self.loggedInBuilder = loggedInBuilder
        super.init(scopeLifecycle: scopeLifecycle, presenter: presenter)
    }

    override func didLoad(_ lifecyclePublisher: LifecyclePublisher) {
        super.didLoad(lifecyclePublisher)

        routeToLoggedOut()
    }

    func routeToLoggedIn(player1Name: String, player2Name: String) {
        // Detach logged out.
        if let loggedOut = self.loggedOut {
            detachChild(loggedOut)
            presenter.dismiss(presenter: loggedOut.presentable)
            self.loggedOut = nil
        }

        let loggedIn = loggedInBuilder.build(.init(player1Name: player1Name,
                                                   player2Name: player2Name))
        attachChild(loggedIn)
    }

    // MARK: - Private

    private func routeToLoggedOut() {
        let loggedOut = loggedOutBuilder.build()
        self.loggedOut = loggedOut
        attachChild(loggedOut)
        presenter.present(presenter: loggedOut.presentable)
    }
}
