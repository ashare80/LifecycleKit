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

final class RootComponent: BootstrapComponent, PresentableInteractorProviding {

    var loggedOutListener: LoggedOutListener {
        return interactor
    }

    var presenter: RootPresenter {
        shared {
            RootPresenter()
        }
    }

    var interactor: RootInteractor {
        weakShared {
            RootInteractor(presenter: presenter,
                           router: router)
        }
    }

    var router: RootRouter {
        return RootRouter(scopeLifecycle: scopeLifecycle,
                          presenter: presenter,
                          loggedOutBuilder: loggedOutBuilder,
                          loggedInBuilder: loggedInBuilder)
    }

    var loggedOutBuilder: PresentableInteractableBuildable {
        return AnyBuilder(component: LoggedOutComponent(parent: self))
    }

    var loggedInBuilder: LoggedInBuildable {
        return AnyDynamicBuilder { LoggedInComponent(parent: self, dynamicDependency: $0).interactable }
    }

    var loggedInPresenter: LoggedInPresentable {
        return presenter
    }
}
