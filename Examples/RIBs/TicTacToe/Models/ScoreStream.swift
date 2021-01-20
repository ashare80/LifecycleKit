//
//  Copyright (c) 2017. Uber Technologies
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

public struct Score: Equatable {
    public let player1Score: Int
    public let player2Score: Int
}

public protocol ScoreStream: AnyObject {
    var score: AnyPublisher<Score, Never> { get }
}

public protocol MutableScoreStream: ScoreStream {
    func updateScore(with winner: PlayerType)
}

public class ScoreStreamImpl: MutableScoreStream {
    
    public init() {}
    
    public var score: AnyPublisher<Score, Never> {
        return variable
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    public func updateScore(with winner: PlayerType) {
        let newScore: Score = {
            let currentScore = variable.value
            switch winner {
            case .player1:
                return Score(player1Score: currentScore.player1Score + 1, player2Score: currentScore.player2Score)
            case .player2:
                return Score(player1Score: currentScore.player1Score, player2Score: currentScore.player2Score + 1)
            }
        }()
        variable.send(newScore)
    }

    // MARK: - Private

    private let variable = CurrentValueSubject<Score, Never>(Score(player1Score: 0, player2Score: 0))
}
