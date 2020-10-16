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

import SPIR

protocol LoggedInPresentable {
    func present(view: Viewable)
    func dismiss(view: Viewable)
}

protocol LoggedInRouter: Routing {
    func routeToOffGame()
    func routeToGame(with gameBuilder: GameBuildable, listener: GameListener)
}

extension LoggedIn {
    final class Router: PresentableRouter<LoggedInPresentable>, LoggedInRouter {
        private let offGameBuilder: ViewableBuildable

        private var currentView: Viewable?

        init(scopeLifecycle: ScopeLifecycle,
             presenter: LoggedInPresentable,
             offGameBuilder: ViewableBuildable)
        {
            self.offGameBuilder = offGameBuilder
            super.init(scopeLifecycle: scopeLifecycle, presenter: presenter)
        }

        override func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {
            super.didBecomeActive(lifecyclePublisher)

            routeToOffGame()
        }

        override func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {
            super.didBecomeInactive(lifecyclePublisher)

            if let currentView = currentView {
                presenter.dismiss(view: currentView)
            }
        }

        func routeToOffGame() {
            detachCurrentChild()
            attachOffGame()
        }

        func routeToGame(with gameBuilder: GameBuildable, listener: GameListener) {
            detachCurrentChild()

            let game = gameBuilder.build(withListener: listener)
            currentView = game
            presenter.present(view: game)
        }

        // MARK: - Private

        private func attachOffGame() {
            let offGame = offGameBuilder.build()
            currentView = offGame
            presenter.present(view: offGame)
        }

        private func detachCurrentChild() {
            if let currentView = currentView {
                presenter.dismiss(view: currentView)
            }
        }
    }
}
