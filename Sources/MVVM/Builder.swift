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
import Lifecycle

public protocol ControllerProviding {
    associatedtype Controller: LifecycleOwner

    var controller: Controller { get }
}

public protocol ViewModelProviding {
    associatedtype ViewModel: ObservableObject, ViewLifecycleOwner

    var viewModel: ViewModel { get }
}

extension ViewLifecycleOwnerViewProviding where Self: ViewModelProviding, ContentView: ViewModelView, ContentView.Model == ViewModel {
    public var view: ContentView {
        return ContentView(model: viewModel)
    }
}

public protocol MVVMComponent: ViewLifecycleOwnerViewProviding, ControllerProviding, ViewModelProviding {}

extension MVVMComponent where Controller == ViewModel {
    public var viewModel: ViewModel {
        return controller
    }
}

extension MVVMComponent {
    public var lifecycleOwner: LifecycleOwner {
        return controller
    }

    public var viewLifecycleOwner: ViewLifecycleOwner {
        return viewModel
    }
}
