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

public protocol OffGameListener: AnyObject {
    func startGame(with gameBuilder: GameBuildable)
}

final class OffGameInteractor: PresentableInteractor<OffGamePresentable>, OffGamePresentableListener {
    private let listener: OffGameListener
    private let scoreBoardBuilder: PresentableInteractableBuildable

    init(presenter: OffGamePresentable,
         listener: OffGameListener,
         scoreBoardBuilder: PresentableInteractableBuildable) {
        self.scoreBoardBuilder = scoreBoardBuilder
        self.listener = listener
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didLoad(_ lifecyclePublisher: LifecyclePublisher) {
        super.didLoad(lifecyclePublisher)
        attachScoreBoard()
    }

    private func attachScoreBoard() {
        let scoreBoard = scoreBoardBuilder.build()
        attachChild(scoreBoard)
        presenter.show(scoreBoardPresenter: scoreBoard.presentable)
    }

    func start(_ game: Game) {
        listener.startGame(with: game.builder)
    }
}
