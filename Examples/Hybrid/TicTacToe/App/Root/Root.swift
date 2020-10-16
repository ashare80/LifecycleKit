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

import MVVM
import SPIR
import SwiftUI

final class Root: BootstrapComponent, MVVMComponent {
    var loggedOutListener: LoggedOutListener {
        return controller
    }

    var loggedOutBuilder: ViewableBuildable {
        return LoggedOut(parent: self)
    }

    var loggedInBuilder: LoggedInBuildable {
        return AnyDynamicBuilder { LoggedIn(parent: self, dynamicDependency: $0).interactable }
    }

    var loggedInPresenter: LoggedInPresentable {
        return viewModel
    }
}

extension Root: ControllerProviding {
    var controller: Controller {
        weakShared {
            Controller(scopeLifecycle: scopeLifecycle,
                       viewModel: viewModel,
                       loggedOutBuilder: loggedOutBuilder,
                       loggedInBuilder: loggedInBuilder)
        }
    }

    final class Controller: ViewModelController<ContentView.Model>, LoggedOutListener {
        private var loggedOut: Viewable?

        private let loggedOutBuilder: ViewableBuildable
        private let loggedInBuilder: LoggedInBuildable

        init(scopeLifecycle: ScopeLifecycle,
             viewModel: Root.ViewModel,
             loggedOutBuilder: ViewableBuildable,
             loggedInBuilder: LoggedInBuildable)
        {
            self.loggedOutBuilder = loggedOutBuilder
            self.loggedInBuilder = loggedInBuilder
            super.init(scopeLifecycle: scopeLifecycle, viewModel: viewModel)
        }

        override func didLoad(_ lifecyclePublisher: LifecyclePublisher) {
            super.didLoad(lifecyclePublisher)
            routeToLoggedOut()
        }

        override func didBecomeInactive(_ lifecyclePublisher: LifecyclePublisher) {
            super.didBecomeInactive(lifecyclePublisher)
        }

        func didLogin(player1Name: String, player2Name: String) {
            // Detach logged out.
            if let loggedOut = self.loggedOut {
                viewModel.dismiss(view: loggedOut)
                self.loggedOut = nil
            }

            let loggedIn = loggedInBuilder.build(.init(player1Name: player1Name,
                                                       player2Name: player2Name))
            attachChild(loggedIn)
        }

        // MARK: - Private

        private func routeToLoggedOut() {
            let loggedOut = loggedOutBuilder.build()
            self.loggedOut = loggedOut
            viewModel.present(view: loggedOut)
        }
    }

}

extension Root: ViewModelProviding {
    var viewModel: ContentView.Model {
        weakShared {
            ContentView.Model()
        }
    }

    struct ContentView: ViewModelView {
        @ObservedObject var model: Model

        var body: some View {
            VStack {
                model.presentedView?.asAnyView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }

        final class Model: ViewLifecycleViewModel, LoggedInPresentable {
            let viewLifecycle: ViewLifecycle = ViewLifecycle()

            @Published var presentedView: Viewable?

            // MARK: - RootPresentable

            func present(view: Viewable) {
                presentedView = view
            }

            func dismiss(view: Viewable) {
                if presentedView === view {
                    presentedView = nil
                }
            }
        }

        #if DEBUG
            struct Preview: PreviewProvider {
                static var previews: some View {
                    ContentView(model: Model())
                }
            }
        #endif
    }
}
