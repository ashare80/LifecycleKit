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
import MVVM
import SwiftUI

public protocol BasicScoreBoardDependency: Dependency {
    var player1Name: String { get }
    var player2Name: String { get }
    var scorePublisher: ScorePublisher { get }
}

final class BasicScoreBoard: Component<BasicScoreBoardDependency>, MVVMComponent {
    var controller: ContentView.Controller {
        weakShared {
            ContentView.Controller(player1Name: dependency.player1Name,
                                   player2Name: dependency.player2Name,
                                   scorePublisher: dependency.scorePublisher.eraseToAnyPublisher())
        }
    }

    struct ContentView: ViewModelView {
        @ObservedObject var model: Controller

        var body: some View {
            VStack {
                Text(model.player1Text)
                    .foregroundColor(.black)
                    .padding(8)
                Text("vs")
                    .foregroundColor(.black)
                    .padding(8)
                Text(model.player2Text)
                    .foregroundColor(.black)
                    .padding(8)
            }
        }

        final class Controller: ViewLifecycleOwnerController, ViewController {
            @Published var player1Text: String = ""
            @Published var player2Text: String = ""

            private let player1Name: String
            private let player2Name: String
            private let scorePublisher: AnyPublisher<Score, Never>

            init(player1Name: String,
                 player2Name: String,
                 scorePublisher: AnyPublisher<Score, Never>) {
                self.player1Name = player1Name
                self.player2Name = player2Name
                self.scorePublisher = scorePublisher
                super.init()
                setText(player1Score: 0, player2Score: 0)
            }

            override func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {
                super.didBecomeActive(lifecyclePublisher)

                scorePublisher
                    .map { score in (score.player1Score, score.player2Score) }
                    .autoCancel(lifecyclePublisher)
                    .sink(receiveValue: setText)
            }

            private func setText(player1Score: Int, player2Score: Int) {
                player1Text = "\(player1Name) (\(player1Score))"
                player2Text = "\(player2Name) (\(player2Score))"
            }
        }

        #if DEBUG
            struct Preview: PreviewProvider {
                static var previews: some View {
                    ContentView(model: Controller(player1Name: "player1Name",
                                                  player2Name: "player2Name",
                                                  scorePublisher: Just(Score(player1Score: 1, player2Score: 2)).eraseToAnyPublisher()))
                }
            }
        #endif
    }
}
