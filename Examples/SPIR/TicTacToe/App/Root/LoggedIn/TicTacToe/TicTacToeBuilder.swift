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

protocol TicTacToeDependency: Dependency {
    var player1Name: String { get }
    var player2Name: String { get }
    var scoreRelay: ScoreRelay { get }
}

final class TicTacToeComponent: Component<TicTacToeDependency>, PresentableInteractorProviding {
    private let dynamicDependency: DynamicDependency

    init(parent: Scope, dynamicDependency: DynamicDependency) {
        self.dynamicDependency = dynamicDependency
        super.init(parent: parent)
    }

    var presenter: TicTacToePresenter {
        return TicTacToePresenter(player1Name: dependency.player1Name,
                                  player2Name: dependency.player2Name)
    }

    var interactor: TicTacToeInteractor {
        return TicTacToeInteractor(presenter: presenter,
                                   listener: dynamicDependency.listener,
                                   scoreRelay: dependency.scoreRelay)
    }

    struct DynamicDependency {
        var listener: TicTacToeListener
    }
}

// MARK: - Builder

protocol TicTacToeBuildable {
    func build(_ dynamicDependency: TicTacToeComponent.DynamicDependency) -> PresentableInteractable
}

extension AnyDynamicBuilder: TicTacToeBuildable where DynamicDependency == TicTacToeComponent.DynamicDependency, R == PresentableInteractable {}
