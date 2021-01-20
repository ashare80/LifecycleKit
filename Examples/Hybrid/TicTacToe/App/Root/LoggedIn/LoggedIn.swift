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

import CombineExtensions
import SPIR

protocol LoggedInDependency: Dependency {
    var loggedInPresenter: LoggedInPresentable { get }
}

final class LoggedIn: Component<LoggedInDependency>, InteractorProviding {

    private let dynamicDependency: DynamicDependency

    init(parent: Scope,
         dynamicDependency: DynamicDependency) {
        self.dynamicDependency = dynamicDependency
        player1Name = dynamicDependency.player1Name
        player2Name = dynamicDependency.player2Name
        super.init(parent: parent)
    }

    public let player1Name: String
    public let player2Name: String

    fileprivate var loggedInPresenter: LoggedInPresentable {
        return dependency.loggedInPresenter
    }

    var games: [Game] {
        return shared {
            return [RandomWinAdapter(randomWinBuilder: AnyDynamicBuilder { RandomWin(parent: self, dynamicDependency: $0).build() }),
                    TicTacToeAdapter(ticTacToeBuilder: AnyDynamicBuilder { TicTacToe(parent: self, dynamicDependency: $0).build() })]
        }
    }

    var offGameListener: OffGameListener {
        return interactor
    }

    var offGameBuilder: ViewableBuildable {
        return AnyBuilder { OffGame(parent: self).build() }
    }

    var router: Router {
        return weakShared {
            return Router(scopeLifecycle: scopeLifecycle,
                          presenter: loggedInPresenter,
                          offGameBuilder: offGameBuilder)
        }
    }

    var interactor: Interactor {
        return weakShared {
            Interactor(router: router)
        }
    }

    var scoreRelay: ScoreRelay {
        return shared { CurrentValueRelay<Score>() }
    }

    var scorePublisher: ScorePublisher {
        return scoreRelay
    }

    struct DynamicDependency {
        let player1Name: String
        let player2Name: String
    }
}

protocol LoggedInBuildable {
    func build(_ dynamicDependency: LoggedIn.DynamicDependency) -> Interactable
}

extension AnyDynamicBuilder: LoggedInBuildable where DynamicDependency == LoggedIn.DynamicDependency, R == Interactable {}
