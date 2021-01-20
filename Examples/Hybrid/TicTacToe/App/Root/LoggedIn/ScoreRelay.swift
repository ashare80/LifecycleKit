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

import Combine
import CombineExtensions

public enum PlayerType: Int, Identifiable {
    case player1 = 1
    case player2

    public var id: Int { rawValue }
}

public struct Score: Equatable {
    public var player1Score: Int = 0
    public var player2Score: Int = 0
}

public protocol ScorePublisher {
    func eraseToAnyPublisher() -> RelayPublisher<Score>
}

public protocol ScoreRelay: ScorePublisher {
    func updateScore(with winner: PlayerType)
}

extension CurrentValueSubject: ScoreRelay, ScorePublisher where Output == Score, Failure == Never {
    public func updateScore(with winner: PlayerType) {
        var score = value
        switch winner {
        case .player1:
            score.player1Score += 1
        case .player2:
            score.player2Score += 1
        }
        send(score)
    }

    public convenience init() {
        self.init(Score())
    }
}
