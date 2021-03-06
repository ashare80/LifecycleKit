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

import Lifecycle
import SPIR
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate, RootLifecycle {

    let rootInteractor = RootComponent().interactor

    var rootLifecycleOwner: LifecycleOwner {
        return rootInteractor
    }

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window

            window.rootViewController = UIHostingController(rootView: rootInteractor.presenter.viewable.asAnyView)
            window.makeKeyAndVisible()

            activateRoot()
        }
    }

    public func application(_: UIApplication, open url: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        return true
    }
}
