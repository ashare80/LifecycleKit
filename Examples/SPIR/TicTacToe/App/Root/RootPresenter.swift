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

final class RootPresenter: Presenter, ViewPresentable, RootPresentable {
    @Published var presentedPresenter: Presentable?

    // MARK: - RootPresentable

    func present(presenter: Presentable) {
        presentedPresenter = presenter
    }

    func dismiss(presenter: Presentable) {
        if presentedPresenter === presenter {
            presentedPresenter = nil
        }
    }

    struct ContentView: PresenterView {
        @ObservedObject var presenter: RootPresenter

        var body: some View {
            VStack {
                presenter.presentedPresenter?.viewable.asAnyView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }

        #if DEBUG
            struct Preview: PreviewProvider {
                static var previews: some View {
                    ContentView(presenter: RootPresenter())
                }
            }
        #endif
    }
}

// MARK: LoggedInPresentable

extension RootPresenter: LoggedInPresentable {}

// MARK: - Preview
