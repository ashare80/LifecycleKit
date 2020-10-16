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

import Foundation
import MVVM
import SwiftUI

public protocol OffGameDependency: Dependency {
    var player1Name: String { get }
    var player2Name: String { get }
    var scorePublisher: ScorePublisher { get }
    var games: [Game] { get }
    var offGameListener: OffGameListener { get }
}

public protocol OffGameListener {
    func startGame(with gameBuilder: GameBuildable)
}

final class OffGame: Component<OffGameDependency>, MVVMComponent {

    var controller: ContentView.Controller {
        return weakShared {
            return ContentView.Controller(games: dependency.games,
                                          listener: dependency.offGameListener,
                                          scoreBoardBuilder: scoreBoardBuilder)
        }
    }

    var scoreBoardBuilder: ViewableBuildable {
        return BasicScoreBoard(parent: self)
    }

    struct ContentView: ViewModelView {
        @ObservedObject var model: Controller

        var body: some View {
            VStack {
                model.scoreBoardView?.asAnyView
                ForEach(0 ..< model.games.count) { index in
                    Button(action: {
                        self.model.start(self.model.games[index])
                    }, label: {
                        Text("Start Game")
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .foregroundColor(Color.white)
                    })
                        .padding(8)
                }
            }
            .background(Color.white)
            .padding(16)
        }

        final class Controller: ViewLifecycleOwnerController, ViewController {
            @Published var scoreBoardView: Viewable?

            let games: [Game]
            private let listener: OffGameListener
            private let scoreBoardBuilder: ViewableBuildable

            init(games: [Game],
                 listener: OffGameListener,
                 scoreBoardBuilder: ViewableBuildable) {
                self.games = games
                self.listener = listener
                self.scoreBoardBuilder = scoreBoardBuilder
                super.init()
            }

            override func didLoad(_ lifecyclePublisher: LifecyclePublisher) {
                super.didLoad(lifecyclePublisher)
                attachScoreBoard()
            }

            private func attachScoreBoard() {
                scoreBoardView = scoreBoardBuilder.build()
            }

            func start(_ game: Game) {
                listener.startGame(with: game.builder)
            }
        }

        #if DEBUG
            struct Preview: PreviewProvider {
                struct OffGameListenerMock: OffGameListener {
                    func startGame(with gameBuilder: GameBuildable) {}
                }

                struct ViewableBuildableMock: ViewableBuildable {
                    func build() -> Viewable {
                        return EmptyView().asViewProvider
                    }
                }

                static var previews: some View {
                    ContentView(model: Controller(games: [], listener: OffGameListenerMock(), scoreBoardBuilder: ViewableBuildableMock()))
                }
            }
        #endif
    }

}
