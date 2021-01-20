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
import SwiftUI

protocol LoggedOutDependency: Dependency {
    var loggedOutListener: LoggedOutListener { get }
}

final class LoggedOutComponent: Component<LoggedOutDependency>, InteractablePresententerProviding {

    var presenter: LoggedOutPresenter {
        return LoggedOutPresenter(listener: dependency.loggedOutListener)
    }
}

protocol LoggedOutListener {
    func didLogin(player1Name: String, player2Name: String)
}

final class LoggedOutPresenter: InteractablePresenter, ViewPresentable, PresentableInteractable {
    @Published var player1: String = ""
    @Published var player2: String = ""

    private let listener: LoggedOutListener

    init(listener: LoggedOutListener) {
        self.listener = listener
        super.init()
    }

    func login(player1Name: String?, player2Name: String?) {
        listener.didLogin(player1Name: playerName(player1Name, withDefaultName: "Player 1"),
                          player2Name: playerName(player2Name, withDefaultName: "Player 2"))
    }

    private func playerName(_ name: String?, withDefaultName defaultName: String) -> String {
        if let name = name {
            return name.isEmpty ? defaultName : name
        } else {
            return defaultName
        }
    }

    func loginButtonTouchUpInside() {
        login(player1Name: player1, player2Name: player2)
    }

    struct ContentView: PresenterView {
        @ObservedObject var presenter: LoggedOutPresenter

        var body: some View {
            VStack {
                TextField("Player 1 name", text: $presenter.player1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Player 2 name", text: $presenter.player2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: presenter.loginButtonTouchUpInside,
                       label: {
                           Text("Login")
                               .padding(8)
                               .frame(maxWidth: .infinity)
                               .background(Color.black)
                               .foregroundColor(Color.white)
                       })
            }
            .background(Color.white)
            .padding(16)
        }

        #if DEBUG
            struct Preview: PreviewProvider {
                struct LoggedOutListenerMock: LoggedOutListener {
                    func didLogin(player1Name: String, player2Name: String) {}
                }

                static var previews: some View {
                    ContentView(presenter: LoggedOutPresenter(listener: LoggedOutListenerMock()))
                }
            }
        #endif
    }
}
