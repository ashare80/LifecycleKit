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

protocol LoggedInPresentable: Presentable {
    func present(presenter: Presentable)
    func dismiss(presenter: Presentable)
}

protocol LoggedInRouting: Routing {
    func cleanupViews()
    func routeToOffGame(with games: [Game])
    func routeToGame(with gameBuilder: GameBuildable, listener: GameListener)
}

final class LoggedInRouter: PresentableRouter<LoggedInPresentable>, LoggedInRouting {
    private let offGameBuilder: PresentableInteractableBuildable

    private var currentChild: PresentableInteractable?

    init(scopeLifecycle: ScopeLifecycle,
         presenter: LoggedInPresentable,
         offGameBuilder: PresentableInteractableBuildable)
    {
        self.offGameBuilder = offGameBuilder
        super.init(scopeLifecycle: scopeLifecycle, presenter: presenter)
    }

    // MARK: - LoggedInRouting

    func cleanupViews() {
        if let currentChild = currentChild {
            presenter.dismiss(presenter: currentChild.presentable)
        }
    }

    func routeToOffGame(with games: [Game]) {
        detachCurrentChild()
        attachOffGame(with: games)
    }

    func routeToGame(with gameBuilder: GameBuildable, listener: GameListener) {
        detachCurrentChild()

        let game = gameBuilder.build(withListener: listener)
        currentChild = game
        attachChild(game)
        presenter.present(presenter: game.presentable)
    }

    // MARK: - Private

    private func attachOffGame(with games: [Game]) {
        let offGame = offGameBuilder.build()
        currentChild = offGame
        attachChild(offGame)
        presenter.present(presenter: offGame.presentable)
    }

    private func detachCurrentChild() {
        if let currentChild = currentChild {
            detachChild(currentChild)
            presenter.dismiss(presenter: currentChild.presentable)
        }
    }
}
