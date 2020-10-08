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
import SPIR

protocol LoggedInInteractable: Interactable, OffGameListener, GameListener {}

final class LoggedInInteractor: RoutingInteractor<LoggedInRouting>, LoggedInInteractable {
    init(router: LoggedInRouting,
         games: [Game]) {
        self.games = games
        super.init(router: router)
    }

    override func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {
        super.didBecomeActive(lifecyclePublisher)

        router.routeToOffGame(with: games)
    }

    override func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {
        super.didBecomeInactive(lifecyclePublisher)

        router.cleanupViews()
    }

    // MARK: - OffGameListener

    func startGame(with gameBuilder: GameBuildable) {
        router.routeToGame(with: gameBuilder, listener: self)
    }

    // MARK: - TicTacToeListener

    func gameDidEnd(with _: PlayerType?) {
        router.routeToOffGame(with: games)
    }

    // MARK: - Private

    private var games = [Game]()
}
