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

class RandomWinAdapter: Game, GameBuildable, RandomWinListener {
    let id = "randomwin"
    let name = "Random Win"
    var builder: GameBuildable {
        return self
    }

    private let randomWinBuilder: RandomWinBuildable

    private weak var listener: GameListener?

    init(randomWinBuilder: RandomWinBuildable) {
        self.randomWinBuilder = randomWinBuilder
    }

    func build(withListener listener: GameListener) -> Viewable {
        self.listener = listener
        return randomWinBuilder.build(.init(listener: self))
    }

    func didRandomlyWin() {
        listener?.gameDidEnd()
    }
}
