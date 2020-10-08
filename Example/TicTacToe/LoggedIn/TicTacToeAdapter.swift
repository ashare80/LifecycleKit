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

class TicTacToeAdapter: Game, GameBuildable, TicTacToeListener {
    let id = "tictactoe"
    let name = "Tic Tac Toe"
    let ticTacToeBuilder: TicTacToeBuildable
    var builder: GameBuildable {
        return self
    }

    weak var gameListener: GameListener?

    init(ticTacToeBuilder: TicTacToeBuildable) {
        self.ticTacToeBuilder = ticTacToeBuilder
    }

    func build(withListener listener: GameListener) -> PresentableInteractable {
        gameListener = listener
        return ticTacToeBuilder.build(.init(listener: self))
    }

    func ticTacToeDidEnd(with winner: PlayerType?) {
        gameListener?.gameDidEnd(with: winner)
    }
}
